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
driver.implicitly_wait(2)

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

# CSV 파일 경로 설정
csv_file_path = "음식점_data.csv"

# CSV 파일에 헤더가 이미 존재하는지 확인 후 추가
def write_to_csv(store_info):
    # 필드 이름을 딕셔너리의 키로 설정
    fieldnames = [
        "category", "storename", "type", "address", "lot_address", 
        "postal_code", "rating", "latitude", "longitude", 
        "images", "hours", "menu", "reviews"
    ]
    
    # 이미 저장된 데이터 확인을 위한 집합
    existing_data = set()
    
    # 파일이 존재할 경우 기존 데이터를 읽어와서 중복 체크를 위한 데이터셋 생성
    if os.path.isfile(csv_file_path):
        with open(csv_file_path, mode='r', newline='', encoding='utf-8') as csvfile:
            reader = csv.DictReader(csvfile)
            for row in reader:
                # 가게 이름과 주소를 조합하여 고유 키 생성
                key = (row['storename'], row['address'])
                existing_data.add(key)

    # 새로 추가하려는 데이터의 고유 키 생성
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
                "images": json.dumps(store_info.get("images", []), ensure_ascii=False),
                "hours": json.dumps(store_info.get("hours", {}), ensure_ascii=False),
                "menu": json.dumps(store_info.get("menu", []), ensure_ascii=False),
                "reviews": json.dumps(store_info.get("reviews", []), ensure_ascii=False),
            })  # 데이터를 작성
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
            name = driver.find_element(By.XPATH, '//div[@class="zD5Nm undefined"]/div[1]/div[1]/span[1]').text
            # "톡톡" 단어가 포함되어 있으면 제거
            storename = name.split("톡톡")[0].strip()  # "톡톡" 앞부분만 추출
            type = driver.find_element(By.XPATH, '//div[@class="zD5Nm undefined"]/div[1]/div[1]/span[2]').text
            address = driver.find_element(By.XPATH, '//span[@class="LDgIH"]').text
            elements = driver.find_elements(By.XPATH, '//span[@class="PXMot LXIwF"]')
            if len(elements) > 1:
                rating = elements[1].text
            else:
                rating = '정보 없음'

            # 정보를 포함하는 span을 클릭하고 대기
            code_button = WebDriverWait(driver, 10).until(
                EC.element_to_be_clickable((By.XPATH, '//span[@class="_UCia"]'))
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

            print(f"카테고리: {search_query}, 가게 이름: {storename}, 종류: {type}, 도로명: {address}, 지번: {lot_address}, 우편번호: {postal_code}, 평점: {rating}:")

            # 주소를 geocode하여 위도와 경도를 가져오는 로직
            location_by_lot = None  # 초기화
            try:
                location_by_lot = geolocator.geocode(lot_address)
                if location_by_lot:
                    latitude = location_by_lot.latitude
                    longitude = location_by_lot.longitude
                    print(f"위도: {latitude}, 경도: {longitude}")
                else:
                    print("주소를 찾을 수 없습니다.")
            except Exception as e:
                print(f"지오코딩 오류 발생: {e}")


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
                button_element = WebDriverWait(driver, 10).until(
                    EC.element_to_be_clickable((By.CSS_SELECTOR, ".gKP9i.RMgN0"))
                )
                driver.execute_script("arguments[0].click();", button_element)  # 버튼 클릭

                # 영업시간을 조회
                hours_section = WebDriverWait(driver, 10).until(
                    EC.visibility_of_element_located((By.CSS_SELECTOR, ".place_section_content .O8qbU.pSavy"))
                )

                # 영업시간 항목 가져오기
                hours_text = hours_section.text  # 전체 텍스트를 가져옵니다.

                # 영업시간을 포맷팅하여 가독성 있게 출력
                if hours_text:
                    lines = hours_text.split("\n")  # 줄 단위로 나누기
                    formatted_hours = {}
                    current_day = ""

                    for line in lines:
                        line = line.strip()  # 공백 제거
                        if line in ["토", "일", "월", "화", "수", "목", "금"]:  # 요일 체크
                            current_day = line  # 현재 요일 저장
                            formatted_hours[current_day] = []  # 새로운 요일 추가
                        elif current_day:  # 현재 요일이 설정된 경우
                            formatted_hours[current_day].append(line)  # 요일에 영업시간 추가

                    print("가게 영업 시간:")
                    for day, hours in formatted_hours.items():
                        print(f"{day}: {' | '.join(hours)}")  # 요일별 영업시간 출력
                else:
                    print("영업시간 정보를 찾을 수 없습니다.")

            except Exception as e:
                print("가게 영업 시간 크롤링 실패:", e)

            # 메뉴 정보 추가 (메뉴 섹션에서 메뉴와 가격 추출)
            try:
                menu_button = WebDriverWait(driver, 10).until(
                    EC.element_to_be_clickable((By.XPATH, '//span[@class="veBoZ" and contains(text(), "메뉴") or @class="txt" and contains(text(), "메뉴")]'))
                )
                menu_button.click()
                sleep(0.2)  # 메뉴 정보 로드를 기다리기 위해 약간의 대기

                # 메뉴 수집을 위한 리스트 초기화
                menu_items = []
                menu_info = []
                menu_prices = []

                # 최대 스크롤 횟수
                max_scrolls = 5
                for _ in range(max_scrolls):
                    # 수집할 수 있는 클래스 목록
                    menu_classes = [
                        {'name': 'lPzHi', 'info': 'kPogF', 'price': 'em'},
                        {'name': 'tit', 'info': 'detail_txt', 'price': 'price'},
                        {'name': 'meDTN', 'info': 'kPogF', 'price': 'GXS1X'},
                    ]

                    # 각 클래스에 대해 반복하여 메뉴 정보 수집
                    for cls in menu_classes:
                        current_items = driver.find_elements(By.CLASS_NAME, cls['name'])  # 메뉴 이름
                        current_info = driver.find_elements(By.CLASS_NAME, cls['info'])  # 메뉴 설명
                        current_prices = driver.find_elements(By.TAG_NAME, cls['price'])  # 메뉴 가격

                        # 현재 수집된 항목을 리스트에 추가 (중복 제거)
                        for item in current_items:
                            if item.text not in menu_items:
                                menu_items.append(item.text)

                        for info in current_info:
                            if info.text not in menu_info:
                                menu_info.append(info.text)

                        for price in current_prices:
                            if price.text not in menu_prices:
                                menu_prices.append(price.text)

                        # 메뉴가 충분히 수집되었다면 루프 종료
                        if len(menu_items) >= 4:
                            break

                    # 스크롤을 위해 페이지를 아래로 이동
                    driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
                    sleep(0.5)  # 스크롤 후 약간 대기

                    # 메뉴가 충분히 수집되었다면 루프 종료
                    if len(menu_items) >= 4:
                        break

                # 수집한 메뉴 정보를 최대 4개로 제한
                menu_list = []
                for item, info, price in zip(menu_items[:4], menu_info[:4], menu_prices[:4]):  # 최대 4개 메뉴만 수집
                    menu_entry = f"{item}: {info} ({price})"  # 각 항목의 텍스트를 사용
                    menu_list.append(menu_entry.strip())  # 공백 제거 후 리스트에 추가

                # 메뉴 정보를 줄바꿈으로 구분하여 저장
                menu_str = '\n'.join(menu_list) if menu_list else '정보 없음'

            except Exception as e:
                print("메뉴 정보 가져오기 실패:", e)
                menu_str = '정보 없음'

            try:
                # 방문자 리뷰 버튼 클릭
                review_button = WebDriverWait(driver, 10).until(
                    EC.element_to_be_clickable((By.XPATH, '//span[@class="veBoZ" and contains(text(), "리뷰") or @class="txt" and contains(text(), "리뷰")]'))
                )
                review_button.click()
                sleep(0.2)  # 리뷰 정보 로드를 기다리기 위해 약간의 대기

                # 리뷰 수집
                reviews_elements = driver.find_elements(By.CLASS_NAME, 'pui__xtsQN-')  # 'pui__xtsQN-' 클래스를 가진 리뷰 항목 찾기

                # 최대 3개의 리뷰를 수집하여 리스트에 추가
                reviews = []
                if reviews_elements:
                    for review in reviews_elements[:1]:  # 최대 3개의 리뷰 가져오기
                        review_text = review.text
                        reviews.append(review_text.strip())
                else:
                    reviews = ['정보 없음']

            except Exception as e:
                print("리뷰 정보 가져오기 실패:", e)

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
                    "reviews": reviews if reviews else [],
                }
                write_to_csv(store_info)  # CSV 파일에 저장
            else:
                print(f"중복된 가게: {storename}를 건너뜁니다.")


        except Exception as e:
            print(f"세부 정보 가져오기 오류: {e}")

        switch_left(driver)

    # 스크롤 가능한 요소 내에서 스크롤 시도
    driver.execute_script("arguments[0].scrollTop += 600;", scrollable_element)
    sleep(0.2)  # 동적 콘텐츠 로드 시간에 따라 조절

# 드라이버 종료
driver.quit()
