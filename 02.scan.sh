#!/bin/bash
export GRYPE_DB_CACHE_DIR=$PWD/cache
echo LOG cache is in: $GRYPE_DB_CACHE_DIR
export GRYPE_DB_AUTO_UPDATE=false
echo LOG db update status:$GRYPE_DB_AUTO_UPDATE
echo Checking Grype status
sudo grype db status
echo STARTING Filesystem scan, this will confirm take quite a while.
sudo grype dir:/ --file grype-fs.cve
echo Filesystem scan completed and saved in grype-fs.cve!

echo .
echo STARTING docker images scan, this may take a while.
for image in $(sudo docker images | tail -n +2 | awk '{print $1":"$2}')
do
    echo $image
    output_path=grype-${image//[\/:]/_}.cve
    sudo grype docker:$image --file $output_path
	#sudo grype docker:$image --file grype-$image.cve
done


echo ALL SCANNING DONE. Summarising results for CVE-2021-44228
for cve in $(ls *.cve)
do
	echo ---- $cve ---- >> $HOSTNAME-CVE-2021-44228.txt
	echo $(cat "$cve" | grep CVE-2021-44228 | awk '{printf "%s,%s,%s,%s\n", $1,$2,$3,$4}' >> $HOSTNAME-CVE-2021-44228.txt)
done
cat $HOSTNAME-CVE-2021-44228.txt

