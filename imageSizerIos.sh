for K in *.png; do 
	N=${K//@2x/}
	convert $K -resize 50% $N; 
done;
