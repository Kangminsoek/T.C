import re
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
driver.implicitly_wait(3)

# 네이버 지도 URL로 이동
search_query = '카페'
search_url = f'https://map.naver.com/search?query={search_query}'
driver.get(search_url)

# 가게 정보를 최대 20개까지만 수집하도록 설정
max_stores = 10
store_count = 0

# geopy 설정
geolocator = Nominatim(user_agent="geoapiExercises")

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
            category = driver.find_element(By.XPATH, '//div[@class="zD5Nm undefined"]/div[1]/div[1]/span[2]').text
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

            # 주소에서 층 정보 등 불필요한 부분 제거
            clean_address = re.sub(r'\d+\.\d*층', '', address).strip()

            # 주소 중에서 "서울 중구 서소문로 116" 형식만 남기기
            clean_address_match = re.search(r'^(서울\s[가-힣]+)\s(.*?)(\d+)', clean_address)
            if clean_address_match:
                clean_address = f"{clean_address_match.group(1)} {clean_address_match.group(2)}{clean_address_match.group(3)}"
            else:
                clean_address = address

            print(f"가게 이름: {store_name}, 카테고리: {category}, 도로명: {clean_address}, 지번: {lot_address}, 우편번호: {postal_code}")

            # 도로명 주소로 지오코딩 시도
            location_by_address = geolocator.geocode(clean_address)
            if location_by_address:
                print(f"도로명 주소로 찾은 위도: {location_by_address.latitude}, 경도: {location_by_address.longitude}")
            else:
                print("도로명 주소로 위도/경도 정보를 찾을 수 없습니다.")

            # 지번으로 지오코딩 시도
            location_by_lot = geolocator.geocode(lot_address)
            if location_by_lot:
                print(f"지번으로 찾은 위도: {location_by_lot.latitude}, 경도: {location_by_lot.longitude}")
            else:
                print("지번으로 위도/경도 정보를 찾을 수 없습니다.")

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
                sleep(1.5)  # 메뉴 정보 로드를 기다리기 위해 약간의 대기

                # 기존 방식으로 메뉴 이름, 설명, 가격 추출
                menu_items = driver.find_elements(By.CLASS_NAME, 'lPzHi')  # 메뉴 이름
                menu_info = driver.find_elements(By.CLASS_NAME, 'kPogF')  # 메뉴 설명
                menu_prices = driver.find_elements(By.TAG_NAME, 'em')  # 메뉴 가격

                # 추가: 예외 케이스 처리 (div, span 태그 사용)
                if not menu_items:  # 기존 방식으로 메뉴를 찾지 못했을 경우
                    menu_items = driver.find_elements(By.CSS_SELECTOR, 'div.tit')  # 메뉴명
                    menu_info = driver.find_elements(By.CSS_SELECTOR, 'span.detail_txt')  # 메뉴 설명
                    menu_prices = driver.find_elements(By.CSS_SELECTOR, 'div.price')  # 메뉴 가격

                # 메뉴 정보 출력 (최대 10개)
                for name, info, price in zip(menu_items[:10], menu_info[:10], menu_prices[:10]):
                    print(f"메뉴: {name.text}, 설명: {info.text}, 가격: {price.text}")

            except Exception as e:
                print("메뉴 정보 가져오기 실패:", e)

            try:
                # 방문자 리뷰 버튼 클릭
                review_button = WebDriverWait(driver, 10).until(
                    EC.element_to_be_clickable((By.XPATH, '//span[@class="veBoZ" and contains(text(), "리뷰")or @class="txt" and contains(text(), "리뷰")]'))
                )
                review_button.click()
                sleep(1.5)  # 리뷰 정보 로드를 기다리기 위해 약간의 대기

                reviews = driver.find_elements(By.CLASS_NAME, 'pui__xtsQN-')  # 'pui__xtsQN-' 클래스를 가진 리뷰 항목 찾기

                # 최대 3개의 리뷰 출력
                for review in reviews[:3]:  # 리뷰 리스트에서 최대 10개 가져오기
                    print(f"리뷰: {review.text}")  # 리뷰 내용 출력

            except Exception as e:
                print("리뷰 정보 가져오기 실패:", e)

        except Exception as e:
            print(f"세부 정보 가져오기 오류: {e}")

        switch_left(driver)

    # 스크롤 가능한 요소 내에서 스크롤 시도
    driver.execute_script("arguments[0].scrollTop += 600;", scrollable_element)
    sleep(1)  # 동적 콘텐츠 로드 시간에 따라 조절

# 드라이버 종료
driver.quit()
