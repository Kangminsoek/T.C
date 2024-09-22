from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from time import sleep

def switch_left(driver):
    driver.switch_to.default_content()
    iframe = WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.XPATH, '//*[@id="searchIframe"]'))
    )
    driver.switch_to.frame(iframe)

def switch_right(driver):
    driver.switch_to.default_content()
    try:
        iframe = WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.XPATH, '//*[@id="entryIframe"]'))
        )
        driver.switch_to.frame(iframe)
    except:
        print("오른쪽 iframe을 찾을 수 없습니다.")

options = webdriver.ChromeOptions()
options.add_argument('user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3')
options.add_argument('window-size=1380,900')
driver = webdriver.Chrome(options=options)

driver.implicitly_wait(3)

search_query = '음식점'
search_url = f'https://map.naver.com/search?query={search_query}'
driver.get(search_url)

max_stores = 20
store_count = 0

while store_count < max_stores:
    switch_left(driver)

    scrollable_element = WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.XPATH, '//*[@id="_pcmap_list_scroll_container"]'))
    )

    elements = driver.find_elements(By.XPATH, '//*[@id="_pcmap_list_scroll_container"]//li')

    for index, e in enumerate(elements[store_count:], start=store_count + 1):
        if store_count >= max_stores:
            break
        
        try:
            ad_badge = e.find_element(By.CLASS_NAME, 'place_ad_label_text')
            print(f"광고 {store_count + 1}번째 항목, 건너뜁니다.")
            store_count += 1
            continue
        except:
            pass

        store_name = e.find_element(By.CLASS_NAME, 'CHC5F').find_element(By.XPATH, ".//a/div/div/span").text
        print(f"{store_count + 1}. {store_name}")
        store_count += 1

        e.find_element(By.CLASS_NAME, 'CHC5F').find_element(By.XPATH, ".//a/div/div/span").click()
        switch_right(driver)

        try:
            store_name = driver.find_element(By.XPATH, '//div[@class="zD5Nm undefined"]/div[1]/div[1]/span[1]').text
            category = driver.find_element(By.XPATH, '//div[@class="zD5Nm undefined"]/div[1]/div[1]/span[2]').text
            address = driver.find_element(By.XPATH, '//span[@class="LDgIH"]').text
            rating = driver.find_element(By.XPATH, '//div[@class="zD5Nm undefined"]/div[2]/span[1]').text
            
            print(f"가게 이름: {store_name}, 카테고리: {category}, 주소: {address}, 평점: {rating}")

            body_element2 = WebDriverWait(driver, 10).until(
                EC.visibility_of_element_located((By.CSS_SELECTOR, "#app-root > div > div > div > div.CB8aP > div"))
            )
            img_elements = body_element2.find_elements(By.TAG_NAME, "img")
            images = [img.get_attribute("src") for img in img_elements if img.get_attribute("src")]
            for img_url in images[:3]:
                print("가게 사진:", img_url)

            try:
                button_element = WebDriverWait(driver, 10).until(EC.element_to_be_clickable((By.CSS_SELECTOR, ".gKP9i.RMgN0")))
                driver.execute_script("arguments[0].click();", button_element)

                body_element3 = WebDriverWait(driver, 10).until(
                    EC.visibility_of_element_located((By.CSS_SELECTOR, "#app-root > div > div > div > div:nth-child(5) > div > div:nth-child(2) > div.place_section_content > div > div.O8qbU.pSavy > div > a"))
                )
                print("가게 영업 시간:", body_element3.text)

            except Exception as e:
                print("가게 영업 시간 크롤링 실패:", e)

        except Exception as e:
            print(f"세부 정보 가져오기 오류: {e}")

        switch_left(driver)

    driver.execute_script("arguments[0].scrollTop += 600;", scrollable_element)
    sleep(1)

driver.quit()
