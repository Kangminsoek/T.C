import re
import csv
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
driver.implicitly_wait(4)

# 네이버 지도 URL로 이동
search_query = '음식점'
search_url = f'https://map.naver.com/search?query={search_query}'
driver.get(search_url)

# 가게 정보를 최대 20개까지만 수집하도록 설정
max_stores = 3
store_count = 0

# geopy 설정
geolocator = Nominatim(user_agent="ccpick")

store_data = []
existing_stores = set()  # 중복 체크를 위한 집합

# CSV 파일 쓰기 함수 정의


def write_to_csv(store_info):
    with open('음식점_data.csv', 'a', newline='', encoding='utf-8') as csvfile:
        fieldnames = store_info.keys()  # 키를 필드 이름으로 사용
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

        # CSV 파일이 비어 있을 경우 헤더를 작성
        if csvfile.tell() == 0:
            writer.writeheader()
        writer.writerow(store_info)  # 데이터를 작성


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
        store_name = e.find_element(By.CLASS_NAME, 'CHC5F').find_element(By.XPATH, ".//a/div/div/span").text
        print(f"{store_count + 1}. {store_name}")
        store_count += 1

        # 가게 클릭 후 정보 가져오기
        e.find_element(By.CLASS_NAME, 'CHC5F').find_element(By.XPATH, ".//a/div/div/span").click()
        switch_right(driver)

        try:
            # 가게 이름, 카테고리, 주소, 평점 수집
            store_name = driver.find_element(By.XPATH, '//div[@class="zD5Nm undefined"]/div[1]/div[1]/span[1]').text
            type = driver.find_element(By.XPATH, '//div[@class="zD5Nm undefined"]/div[1]/div[1]/span[2]').text
            address = driver.find_element(By.XPATH, '//span[@class="LDgIH"]').text
            rating = driver.find_element(By.XPATH, '//div[@class="zD5Nm undefined"]/div[2]/span[1]').text

            # 정보를 포함하는 span을 클릭하고 대기
            code_button = WebDriverWait(driver, 10).until(
                EC.element_to_be_clickable((By.XPATH, '//span[@class="_UCia"]'))
            )
            code_button.click()
            sleep(1)  # 버튼 클릭 후 페이지 로딩을 기다리는 시간 증가

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

            print(f"카테고리: {search_query}, 가게 이름: {store_name}, 종류: {type}, 도로명: {address}, 지번: {lot_address}, 우편번호: {postal_code}")

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

            # 요청 사이에 대기 시간 추가
            sleep(1)

            # 가게 사진 조회 (최대 3개)
            body_element2 = WebDriverWait(driver, 10).until(
                EC.visibility_of_element_located((By.CSS_SELECTOR, "#app-root > div > div > div > div.CB8aP > div"))
            )
            img_elements = body_element2.find_elements(By.TAG_NAME, "img")
            images = [img.get_attribute("src") for img in img_elements if img.get_attribute("src")]
            for img_url in images[:3]:  # 최대 3개만 출력
                print("가게 사진:", img_url)

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
                        if line in ["토", "일", "월", "화", "수", "목", "금"]:  # 요일 확인
                            current_day = line
                        else:
                            formatted_hours[current_day] = line  # 요일과 영업시간 매핑

                    for day, hours in formatted_hours.items():
                        print(f"{day}: {hours}")
                else:
                    print("영업시간 정보를 찾을 수 없습니다.")
            except Exception as e:
                print(f"영업시간 오류: {e}")

            # 메뉴 정보 추가 (메뉴 섹션에서 메뉴와 가격 추출)
            try:
                menu_button = WebDriverWait(driver, 10).until(
                    EC.element_to_be_clickable((By.XPATH, '//span[@class="veBoZ" and contains(text(), "메뉴") or @class="txt" and contains(text(), "메뉴")]'))
                )
                menu_button.click()
                sleep(1.5)  # 메뉴 정보 로드를 기다리기 위해 약간의 대기

                # 초기 메뉴 수집 시도
                menu_items = driver.find_elements(By.CLASS_NAME, 'lPzHi')  # 메뉴 이름
                menu_info = driver.find_elements(By.CLASS_NAME, 'kPogF')  # 메뉴 설명
                menu_prices = driver.find_elements(By.TAG_NAME, 'em')  # 메뉴 가격

                # 메뉴 정보를 리스트에 추가
                menu_list = []

                # 기존 방식으로 수집한 메뉴가 없을 경우 대체 방법으로 시도
                if not menu_items:
                    menu_items = driver.find_elements(By.CSS_SELECTOR, 'div.tit')  # 대체 메뉴명
                    menu_info = driver.find_elements(By.CSS_SELECTOR, 'span.detail_txt')  # 대체 메뉴 설명
                    menu_prices = driver.find_elements(By.CSS_SELECTOR, 'div.price')  # 대체 메뉴 가격

                # 각 방식으로 수집한 메뉴 정보를 하나의 리스트에 통합
                for item, info, price in zip(menu_items, menu_info, menu_prices):
                    menu_entry = f"{item.text}: {info.text} ({price.text})"  # 각 항목의 텍스트를 사용
                    menu_list.append(menu_entry.strip())  # 공백 제거 후 리스트에 추가

                # 메뉴 정보를 줄바꿈으로 구분하여 저장
                menu_str = '\n'.join(menu_list) if menu_list else '정보 없음'

            except Exception as e:
                print("메뉴 정보 가져오기 실패:", e)

            try:
                # 방문자 리뷰 버튼 클릭
                review_button = WebDriverWait(driver, 10).until(
                    EC.element_to_be_clickable((By.XPATH, '//span[@class="veBoZ" and contains(text(), "리뷰") or @class="txt" and contains(text(), "리뷰")]'))
                )
                review_button.click()
                sleep(1.5)  # 리뷰 정보 로드를 기다리기 위해 약간의 대기

                # 리뷰 수집
                reviews_elements = driver.find_elements(By.CLASS_NAME, 'pui__xtsQN-')  # 'pui__xtsQN-' 클래스를 가진 리뷰 항목 찾기

                # 최대 3개의 리뷰를 수집하여 리스트에 추가
                reviews = []
                for review in reviews_elements[:3]:  # 리뷰 리스트에서 최대 3개 가져오기
                    review_text = review.text
                    reviews.append(review_text.strip())  # 리뷰 내용을 리스트에 추가
                    print(f"리뷰: {review_text}")  # 리뷰 내용 출력

            except Exception as e:
                print("리뷰 정보 가져오기 실패:", e)



            # 중복 확인 후 데이터 저장
            if store_name not in existing_stores:
                existing_stores.add(store_name)  # 가게 이름을 집합에 추가
                store_info = {
                    "category": search_query,
                    "store_name": store_name,
                    "type": type,
                    "address": address,
                    "lot_address": lot_address,
                    "postal_code": postal_code,
                    "rating": rating,
                    "latitude": latitude,
                    "longitude": longitude,
                    "images": ', '.join(images[:3]),
                    "hours": hours_text if 'hours_text' in locals() and hours_text else '정보 없음',  # 
                    "menu": menu_str,# 메뉴 정보 추가
                    "reviews": '; '.join(reviews) if reviews else '정보 없음'  # 리뷰 정보 추가
                }
                write_to_csv(store_info)  # CSV 파일에 저장
            else:
                print(f"중복된 가게: {store_name}를 건너뜁니다.")

        except Exception as e:
            print(f"가게 정보를 가져오는 중 오류 발생: {e}")
        finally:
            driver.switch_to.default_content()  # 기본 프레임으로 전환
            sleep(1)  # 다음 가게 클릭 전 잠시 대기

# 브라우저 종료
driver.quit()
