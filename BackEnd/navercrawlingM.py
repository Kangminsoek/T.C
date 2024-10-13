import re
import os
import csv
import json
from geopy.geocoders import Nominatim
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from time import sleep

# 함수 정의: iframe을 전환하는 함수들
def switch_left(driver):
    driver.switch_to.default_content()  # 기본 프레임으로 전환
    iframe = WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.XPATH, '//*[@id="searchIframe"]'))
    )
    driver.switch_to.frame(iframe)

def switch_right(driver):
    driver.switch_to.default_content()  # 기본 프레임으로 전환
    try:
        iframe = WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.XPATH, '//*[@id="entryIframe"]'))
        )
        driver.switch_to.frame(iframe)
    except:
        print("오른쪽 iframe을 찾을 수 없습니다.")

# 크롬 드라이버 설정
options = webdriver.ChromeOptions()
options.add_argument('user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3')
options.add_argument('window-size=1380,900')
driver = webdriver.Chrome(options=options)

# 대기 시간 설정
driver.implicitly_wait(1.5)

# 네이버 지도 URL로 이동
search_query = '강남역 음식집'
search_url = f'https://map.naver.com/search?query={search_query}'
driver.get(search_url)

# 가게 정보를 최대 20개까지만 수집하도록 설정
max_stores = 5
store_count = 0

# geopy 설정
geolocator = Nominatim(user_agent="ccpick")

store_data = []
existing_stores = set()  # 중복 체크를 위한 집합


def write_to_csv(store_info):
    # 필드 이름을 딕셔너리의 키로 설정
    fieldnames = [
        "category", "storename", "type", "address", "lot_address", 
        "postal_code", "rating", "latitude", "longitude", 
        "images", "hours", "menu"
    ]

    # CSV 파일 경로 설정
    csv_file_path = "음식점_data.csv"
    
    # 이미 저장된 데이터 확인을 위한 집합
    existing_data = set()
    
    if os.path.isfile(csv_file_path):
        with open(csv_file_path, mode='r', newline='', encoding='utf-8') as csvfile:
            reader = csv.DictReader(csvfile)
            for row in reader:
                key = (row['storename'], row['address'])
                existing_data.add(key)

    new_data_key = (store_info.get("storename", ""), store_info.get("address", ""))

    # 중복되지 않으면 데이터를 추가
    if new_data_key not in existing_data:
        with open(csv_file_path, mode='a', newline='', encoding='utf-8') as csvfile:
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

            # CSV 파일이 비어 있을 경우 헤더를 작성
            if csvfile.tell() == 0:
                writer.writeheader()

            # 데이터를 작성
            writer.writerow({
                "category": store_info.get("category", ""),
                "storename": store_info.get("storename", ""),
                "type": store_info.get("type", ""),
                "address": store_info.get("address", ""),
                "lot_address": store_info.get("lot_address", ""),
                "postal_code": store_info.get("postal_code", ""),
                "rating": store_info.get("rating", ""),
                "latitude": store_info.get("latitude", ""),
                "longitude": store_info.get("longitude", ""),
                "images": json.dumps(store_info.get("images", []), ensure_ascii=False),  # JSON으로 변환하여 저장
                "hours": json.dumps(store_info.get("hours", {}), ensure_ascii=False),     # JSON으로 변환하여 저장
                "menu": json.dumps(store_info.get("menu", []), ensure_ascii=False),  # 메뉴를 JSON으로 저장
            })
        print("새 데이터가 성공적으로 추가되었습니다!")
    else:
        print("중복 데이터가 감지되어 추가하지 않았습니다.")

while store_count < max_stores:
    switch_left(driver)

    # 스크롤 가능한 요소 찾기
    scrollable_element = WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.XPATH, '//*[@id="_pcmap_list_scroll_container"]'))
    )

    elements = driver.find_elements(By.XPATH, '//*[@id="_pcmap_list_scroll_container"]//li')

    for index, e in enumerate(elements[store_count:], start=store_count + 1):
        if store_count >= max_stores:
            break
        
        # 광고 항목 제외
        try:
            ad_badge = e.find_element(By.CLASS_NAME, 'place_ad_label_text')  # 광고를 나타내는 클래스
            print(f"광고 {store_count + 1}번째 항목, 건너뜁니다.")
            store_count += 1  # 광고 항목도 포함
            continue
        except:
            pass

        # 가게 이름 추출
        name = e.find_element(By.CLASS_NAME, 'place_bluelink').text
        print(f"{store_count + 1}. {name}")
        store_count += 1

        # 가게 클릭 후 정보 가져오기
        e.find_element(By.CLASS_NAME, 'place_bluelink').click()
        switch_right(driver)


        try:
            # 가게 이름, 카테고리, 주소, 평점 수집
            storename = driver.find_element(By.XPATH, '//span[@class="GHAhO"]').text  # 가게 이름 추출
            type = driver.find_element(By.XPATH, '//span[@class="lnJFt"]').text  # 가게 종류 추출
            address = driver.find_element(By.XPATH, '//span[@class="LDgIH"]').text
            elements = driver.find_elements(By.XPATH, '//span[@class="PXMot LXIwF"]')

            if elements:
                rating = elements[-1].text.strip()  # 마지막 요소의 텍스트 가져오기 (별점 뒤에 있는 숫자)
                # '별점'이 포함된 경우 제거
                if '별점' in rating:
                    rating = rating.replace('별점', '').strip()
                else:
                    rating = '정보 없음'  # 또는 원하는 기본값

            # 정보를 포함하는 span을 클릭하고 대기
            code_button = WebDriverWait(driver, 10).until(
                EC.element_to_be_clickable((By.XPATH, '//span[@class="LDgIH"]'))
            )
            code_button.click()
            sleep(0.2)  # 버튼 클릭 후 페이지 로딩을 기다리는 시간 증가

            # div.Y31Sf 안의 텍스트 수집
            y31sf_text = driver.find_element(By.XPATH, '//div[@class="Y31Sf"]').text.strip()

            # 텍스트를 줄바꿈으로 나누기
            lines = y31sf_text.split("\n")

            # 지번과 우편번호 추출
            lot_address = ''
            postal_code = ''

            for i, line in enumerate(lines):
                # '지번'이 포함된 줄에서 지번 주소 추출
                if '지번' in line:
                    lot_address = line.split("지번")[-1].strip().replace("복사", "").strip()
                # '우편번호'가 포함된 줄의 바로 다음 줄에서 우편번호 추출
                if '우편번호' in line and i + 1 < len(lines):
                    postal_code = lines[i + 1].strip().replace("복사", "").strip()

            # 위도와 경도 추출
            location_by_lot = None  # 초기화
            try:
                location_by_lot = geolocator.geocode(lot_address)
                if location_by_lot:
                    latitude = location_by_lot.latitude
                    longitude = location_by_lot.longitude
                else:
                    latitude = longitude = '정보 없음'
            except Exception as e:
                latitude = longitude = '지오코딩 오류 발생'

            # 출력 형식 개선
            print("==============================================")
            print(f"카테고리: {search_query}")
            print(f"가게 이름: {storename}")
            print(f"종류: {type}")
            print(f"도로명: {address}")
            print(f"지번: {lot_address}")
            print(f"우편번호: {postal_code}")
            print(f"평점: {rating}")
            print(f"위도: {latitude}, 경도: {longitude}")
            print("==============================================")

            # 가게 사진 조회 (최대 3개)
            body_element2 = WebDriverWait(driver, 10).until(
                EC.visibility_of_element_located((By.CSS_SELECTOR, "#app-root > div > div > div > div.CB8aP > div"))
            )
            img_elements = body_element2.find_elements(By.TAG_NAME, "img")
            images = [img.get_attribute("src") for img in img_elements if img.get_attribute("src")]

            # 최대 3개의 이미지 URL만 사용
            images = images[:3]

            # 영업시간 조회
            try:
                # 정보를 포함하는 span을 클릭하고 대기
                code_button = WebDriverWait(driver, 10).until(
                    EC.element_to_be_clickable((By.XPATH, '//span[@class="U7pYf"]'))
                )
                code_button.click()

                # 영업시간을 조회
                hours_section = WebDriverWait(driver, 10).until(
                    EC.visibility_of_element_located((By.CSS_SELECTOR, ".place_section_content .O8qbU.pSavy"))
                )

                # 영업시간 항목 가져오기
                hours_text = hours_section.text  # 전체 텍스트를 가져옵니다.
                
                # 영업시간을 포맷팅하여 가독성 있게 출력
                formatted_hours = {}  # 영업시간 정보를 저장할 딕셔너리 초기화

                if hours_text:
                    lines = hours_text.split("\n")  # 줄 단위로 나누기
                    current_day = ""

                    for line in lines:
                        line = line.strip()  # 공백 제거
                        if line in ["토", "일", "월", "화", "수", "목", "금"]:  # 요일 체크
                            current_day = line  # 현재 요일 저장
                            formatted_hours[current_day] = []  # 새로운 요일 추가
                        elif current_day:  # 현재 요일이 설정된 경우
                            formatted_hours[current_day].append(line)

                    # 영업시간 출력
                    print("가게 영업 시간:")
                    if formatted_hours:
                        for day, hours in formatted_hours.items():
                            print(f"{day}: {' | '.join(hours)}")  # 요일별 영업시간 출력
                    else:
                        alternative_info_section = WebDriverWait(driver, 10).until(
                            EC.visibility_of_element_located((By.CSS_SELECTOR, "span.A_cdD"))  # 대체 정보의 CSS 선택자
                        )
                        alternative_info_text = alternative_info_section.text  # 대체 정보를 가져옵니다.
                        formatted_hours["대체 정보"] = alternative_info_text  # 대체 정보를 딕셔너리에 추가
                        print("대체 영업시간 정보:", alternative_info_text)
            
            except Exception as e:
                print("가게 영업 시간 크롤링 실패:", e)



            # 메뉴 정보 추가 (메뉴 섹션에서 메뉴와 가격 추출)
            try:
                menu_button = WebDriverWait(driver, 10).until(
                    EC.element_to_be_clickable((By.XPATH, '//span[@class="veBoZ" and contains(text(), "메뉴") or @class="txt" and contains(text(), "메뉴")]'))
                )
                menu_button.click()
                sleep(0.2)  # 메뉴 정보 로드를 기다리기 위해 약간의 대기

                # 메뉴 수집을 위한 다양한 방법 시도
                menu_items = driver.find_elements(By.CLASS_NAME, 'lPzHi')  # 메뉴 이름
                menu_prices = driver.find_elements(By.TAG_NAME, 'em')  # 메뉴 가격

                # 수집한 메뉴가 없을 경우 대체 방법으로 시도
                if not menu_items:
                    menu_items = driver.find_elements(By.CSS_SELECTOR, 'div.tit')  # 대체 메뉴명
                    menu_prices = driver.find_elements(By.CSS_SELECTOR, 'div.price')  # 대체 메뉴 가격

                # 수집한 메뉴가 없을 경우 마지막 대체 방법으로 시도
                if not menu_items:
                    menu_items = driver.find_elements(By.CSS_SELECTOR, 'div.meDTN')  # 메뉴명
                    menu_prices = driver.find_elements(By.CSS_SELECTOR, 'div.GXS1X')  # 메뉴 가격

                # 각 방식으로 수집한 메뉴 정보를 하나의 리스트에 통합
                menu_list = []
                for item, price in zip(menu_items[:4], menu_prices[:4]):  # 최대 4개 메뉴만 수집
                    menu_entry = f"{item.text} ({price.text})"  # 메뉴명과 가격만 사용
                    menu_list.append(menu_entry.strip())  # 공백 제거 후 리스트에 추가

                # 메뉴 정보를 줄바꿈으로 구분하여 저장
                menu_str = '\n'.join(menu_list) if menu_list else '정보 없음'

            except Exception as e:
                print("메뉴 정보 가져오기 실패:", e)

            # 중복 확인 후 데이터 저장
            normalized_name = storename.strip().lower()  # 가게 이름 정규화 (공백 제거 및 소문자 변환)

            if normalized_name not in existing_stores:
                existing_stores.add(normalized_name)  # 정규화된 가게 이름을 집합에 추가
                # 이후, 크롤링한 정보를 store_info에 저장하고 write_to_csv 호출
                store_info = {
                    "category": search_query,
                    "storename": storename,
                    "type": type,
                    "address": address,
                    "lot_address": lot_address,
                    "postal_code": postal_code,
                    "rating": rating if rating != '정보 없음' else None,
                    "latitude": float(latitude),
                    "longitude": float(longitude),
                    "images": images,
                    "hours": formatted_hours if formatted_hours else {},
                    "menu": menu_str,
                }
                write_to_csv(store_info)  # CSV 파일에 저장
            else:
                print(f"중복된 가게: {storename}를 건너뜁니다.")


        except Exception as e:
            print(f"세부 정보 가져오기 오류: {e}")

        switch_left(driver)

    # 스크롤 가능한 요소 내에서 스크롤 시도
    driver.execute_script("arguments[0].scrollTop += 600;", scrollable_element)
    sleep(0.1)  # 동적 콘텐츠 로드 시간에 따라 조절

# 드라이버 종료
driver.quit()
