import requests
from bs4 import BeautifulSoup
import pandas as pd

req = requests.get('https://code.s3.yandex.net/learning-materials/data-analyst/festival_news/index.html')
soup = BeautifulSoup(req.text, 'lxml')
table = soup.find('table', attrs={'id':'best_festivals'})
heading_table = []
for row in table.find_all('th'):
    heading_table.append(row.text)
content = []
for row in table.find_all('tr'):
    if not row.find_all('th'):
        content.append([element.text for element in row.find_all('td')])
festivals = pd.DataFrame(content, columns=heading_table)
#print(festivals)
print(row)
print(row.text)