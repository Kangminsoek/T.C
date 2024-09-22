from selenium.webdriver.common.by import By

def switch_left(driver):
    # 왼쪽 iframe으로 전환
    driver.switch_to.default_content()
    iframe = driver.find_element(By.XPATH, '//*[@id="searchIframe"]')
    driver.switch_to.frame(iframe)

def switch_right(driver):
    # 오른쪽 iframe으로 전환
    driver.switch_to.default_content()
    iframe = driver.find_element(By.XPATH, '//*[@id="entryIframe"]')
    driver.switch_to.frame(iframe)
