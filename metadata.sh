#IDv2 tag info for 2015-03-05 07:11:21 [불금쇼26회-잔반처리] ⑮ 성인용품 업자가 주목하는 불금쇼.mp3:
#TDRC=2015
#TIT2=⑮ 성인용품 업자가 주목하는 불
#TPE1=정영진 최욱
#TALB=정영진의 불금쇼
#COMM=ID3v1 Comment='eng'=¹Ìµð¾îÇùµ¿Á¶ÇÕ ±¹¹Î¶óµð¿À
#TCON=Vocal

#total=119
total=273
num=0
#find 불금쇼/S1 -type f | sort -h | while read fpath
find 불금쇼/S2 -type f -name "*.mp3" | sort -h | while read fpath
do
    num=$(expr $num + 1)

    IFS='/' read -ra file <<< $fpath
#    mv "$fpath" "${file[0]}/${file[1]}/$(printf %03d $num) - ${file[2]}"

    IFS=' ' read -ra date <<< ${file[2]}
    date=${date[0]}

    title="${file[2]:20}"
    title=${title%.mp3}
    title=${title//'"'/''}
    title=${title//"'"/""}
echo "$num, $date, $title"

    mid3v2 --date=$date --song="$title" --artist="정영진 최욱" --album="정영진 최욱의 불금쇼 시즌2" --track=$num/$total "$fpath"
#    mid3v2 "$fpath"
done
