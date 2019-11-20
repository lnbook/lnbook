D=$(wc ../bitcoinbook/ch* | grep "total" | awk '{print $3}')
N=$(wc ch* | grep "total" | awk '{print $3}')
echo 'print("{:2.2f} % Chars of Mastering Bitcoin".format('$N'*100/'$D'))' | python3
