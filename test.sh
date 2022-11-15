grep $1 seasons.xml > /dev/null
if [ $? -eq 0 ] 
then 
    echo "found it"
else 
    echo "not here bro"
fi 