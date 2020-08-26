e = $z.lines.map { _1[8,96] };
crd = ->i, j {
  j<12?[i/2,2*j+i%2-12]:(a=((i*36+(j-12))*19%3384);[a/72,12+a%72])
};

94.times { |i|
  s=(r=0..47).map { j,k=crd[i,_1]; e[j][k] } * '';
  rs[s];
  r.map{
    j,k=crd[i,_1];
    e[j][k]=s[_1]
  }
}
