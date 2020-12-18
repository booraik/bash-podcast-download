#https://idmango.com/38
import requests
import json
import pathlib
import os
import re

# 목록 추출 URL
#s_url = "http://www.podbbang.com/_m_api/podcasts/12548/episodes?episode_id=0&sort=desc&offset=0&limit=8&with=summary&cache=0"
s_url = "http://www.podbbang.com/_m_api/podcasts/9917/episodes?offset=0&sort=pubdate:asc&episode_id=0&limit=10000&with=summary&cache=0"

g_folder = "/home/media/podcasts/불금쇼/"   # 다운받을 폴더 경로
#headers = {'Referer': 'http://www.podbbang.com/ch/7290'}
headers = {'Referer': 'http://www.podbbang.com/ch/9917'}

# 실제 파일 다운로드 함수
# ----------------------------------------------------------------------
def download(url, file_name, reff):
    with open(file_name, "wb") as file:   # open in binary mode
        response = requests.get(url, headers=reff)               # get request
        file.write(response.content)      # write to file
# ----------------------------------------------------------------------
# 다운로드 호출 함수
# ----------------------------------------------------------------------
# URL , ID, 제목
def get_mp3(s_url, s_id, s_title):
    file = pathlib.Path( g_folder + "/" + s_id + ".mp3")
    if file.exists():
        print ("File exist")
    else:
        download(s_url, g_folder + "/" + s_id + ".mp3", headers )

def get_mp3_2(date, title, url):
    fname =  g_folder + "/" + date + " " + title.replace('/', '_') + ".mp3"
    file = pathlib.Path(fname)
    if not file.exists():
        download(url, fname, headers )


# Main 부분
# ----------------------------------------------------------------------
req = requests.get(s_url)  # URL을 호출하여 JSON 파일을 읽어 옵니다.
data = json.loads(req.content.decode())  # 결괄,ㄹ Decoe 사여 json 파싱을 합니다.
#print(data)

for i, item in enumerate(data['data']): # cont['data']['children']:
    print('[' + str(i) + '] ' + item['published_at'] + ', ' + item['title'] + ', ' + item['enclosure']['url'] )
    get_mp3_2(item['published_at'], item['title'], item['enclosure']['url'])
# ----------------------------------------------------------------------
