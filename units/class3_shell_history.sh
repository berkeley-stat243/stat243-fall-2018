export PS1="$ \w> "
ls
grep -l 'example.pdf' unit3-dataIO.R
ls -tr *.R | tail -n 5
ls -tr *.R 
ls -ltr *.R 
ls -ltr *.R | grep pdf 
ls -ltr *.R | grep optim
ls -tr *.R | tail -n 5 | xargs grep 'example.pdf'
ls -tr *.R | tail -n 7 | xargs grep 'example.pdf'
ls -tr * | tail -n 7 
ls -tr *.R | tail -n 7 | xargs grep -l 'example.pdf'
echo "asdf" > atR
ls *.R
ls *tR
grep --no-filename "^library" *.R
grep --no-filename "^library" *.R | sort | uniq
grep --no-filename "^library" *.R | sort | uniq | cut -d'#' -f1
grep --no-filename "^library" *.R | sort | uniq | cut -d'#' -f1 | tee libs.txt
grep --no-filename "^library" *.R | sort | uniq | cut -d'#' -f1 | sort | uniq | tee libs.txt
less libs.txt 
grep --no-filename "^library" *.R | sort | uniq | cut -d'#' -f1 | sort | uniq | tee libs.txt
grep -v "help =" libs.txt > tmp2.txt
less tmp2.txt 
sed 's/;/\n/g' tmp2.txt | sed 's/ //g' | sed 's/library(//' | sed 's/)//g' > libs.txt
less libs.txt 
sed 's/;/\\\n/g' tmp2.txt | sed 's/ //g' | sed 's/library(//' | sed 's/)//g' > libs.txt
less libs.txt 
echo "There are $(wc -l libs.txt | cut -d' ' -f1) \
we will install."
less libs.txt
wc -l libs.txt 
wc -l libs.txt | cut -d' ' -f1
wc -l libs.txt | sed 's/ cut -d' ' -f4
libs.txt | sed 's/ cut -d' ' -f5
wc -l libs.txt | cut -d' ' -f5
wc -l libs.txt | cut -d' ' -f6
wc -l libs.txt | cut -d' ' -f7
echo "There are $(wc -l libs.txt | cut -d' ' -f7) \
we will install."
less libs.txt 
ssh smeagol.berkeley.edu
ls
grep bash unit2-bash.sh 
grep bash unit2-bash.sh | wc -l
grep -o bash unit2-bash.sh 
grep -o bash unit2-bash.sh |wc -l
echo "There are $(grep -o bash unit2-bash.sh |wc -)l occurrences of the word 'bash' in this file."
echo "There are $(grep -o bash unit2-bash.sh |wc -l) occurrences of the word 'bash' in this file."
history | tail -n 75 | tr -s ' ' | cut -d' ' -f3- > class3_shell_history.sh
