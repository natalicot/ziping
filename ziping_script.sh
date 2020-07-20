#!/bin/bash

#Write a bash script that recieves a location in the filesystem, iterate through files (recursively if  -r flag is sent),
#and check, if a file is not compressed, zip it under name "zipped-<original name>" and remove the old one.
#If file is compressed - will move it to name “zipped-<original name>” and 'touch' it
#If file is called “zipped-*” AND is older than 48 hours - will rm it
#If file is a folder - will go over all non-folder files in it
#If in recursive mode - will also follow folders recursively
#synopsis : zipped -r folder

check_location()
{
i=0
location=$1

while read direction
do
arr[i]=$direction
let i++
done < <(find ~/ -type d -name "*$location*")
k=1
if [ $i -gt 1 ];
then
echo "there are fiew files match your discription: "
for dir in ${arr[@]}
do
echo "$k) $dir"
let k++
done
read -p "please choose the num of file you ment: " num
let num=num-1
loc=${arr[num]}
elif [ $i -eq 0 ]
then
return 0
fi
return 1


}

zip_file()
{
filepath=$1
new_name=$(dirname "${filepath}")/zipped-$(basename "${filepath}")

if file "$filepath" | grep -q "Zip archive" ; then
    case $filepath in
        (*zipped*) touch $filepath;;
        (*) mv $filepath $new_name touch $new_name;;
    esac
else
 zip -m $new_name $filepath
fi
}



if [ "$1" == "-r" ] ; then
flag=1
shift
else
flag=0
fi

loc=$1
check_location $1



if [ $? -gt 0 ] ;
then
echo "path is valid"
else
echo "path not valid"
exit 1
fi

if [ $flag -eq 1 ]; then
find $loc -type f -name 'zipped-*' -mtime +2 -delete
for file in $(find ${loc} -type f); do

zip_file $file
done
else
find $loc -maxdepth 1 -type f  -name 'zipped-*' -mtime +2 -delete
for file in $(find ${loc} -maxdepth 1 -type f); do
zip_file $file
done
fi