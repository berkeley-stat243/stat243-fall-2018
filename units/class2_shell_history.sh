cd Desktop/stat243-fall-2018/
git pull
cd ..
ls
git clone https://github.com/berkeley-stat243/stat243-fall-2017
cd stat243-fall-2017
ls
ls -l
cd data
ls
ls -l
gunzip coop.txt.gz 
ls -l
less coop.txt 
less cpds.csv 
cut -d',' -f2 cpds.csv 
cut -d',' -f2 cpds.csv | less 
man cut
cut -b50-70 coop.txt | less 
cut -b60-61 coop.txt 
cut -b60-61 coop.txt | less
cut -b60-61 coop.txt | less
cut -b60-61 coop.txt | sort | uniq 
echo "3\n4\4\3" > tmp.txt
less tmp.txt 
echo "3
4
4
tmp.txt
less tmp.txt 
uniq tmp.txt
cat tmp.txt
cut -b60-61 coop.txt | sort | uniq | nl
cut -b60-61 coop.txt | sort | uniq | wc
cut -b60-61 coop.txt | sort | uniq | nl | less
cut -b60-61 coop.txt | sort | uniq | wc -l-l 
mv coop.txt ~/
cd 
cut -b60-61 coop.txt | sort | uniq | wc -l
cut -b60-61 coop.txt | sort | uniq > states.txt
less states.txt 
cut -b60-61 coop.txt | sort | uniq -c
cd -
grep Australia cpds.csv 
grep -o Australia cpds.csv 
cd -
tail -n 1 cpds.csv | grep -o ',' | wc -l
cp Desktop/stat243-fall-2017/data/cpds.csv .
tail -n 1 cpds.csv | grep -o ',' | wc -l
tail -n 1 cpds.csv | grep -o ',' 
tail -n 1 cpds.csv | grep -o ',' | wc -l
tail -n 1 cpds.csv | grep -o ',' | wc -l
nfields=$(tail -n 1 cpds.csv | grep -o ',' | wc -l)
echo $nfields
nfields=$(echo "${nfields}+1" | bc)
echo $nfields
tail -n 1 cpds.csv > tmp.txt
echo "," >> tmp.txt
less tmp.txt 
history | tail -n 70 | tr -s ' ' | cut -d' ' -f3- > class2_shell_history.sh
