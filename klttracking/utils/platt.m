function y=platt(x,ab)
  
y = 1 ./ ( 1+exp( (ab(1)*x+ab(2)) ) );

end
