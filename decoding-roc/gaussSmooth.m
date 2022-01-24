function Z = gaussSmooth(X,sig)% Z = gaussSmooth(X,sig)% X is either a row vector or 2 column matrix, with first column = time	b = size(X);	if b(2) == 2		x = X(:,2)';	else		x = X;	end	% gaussin filter	w = sig * 5;	t = -w : w;	y = normpdf(t,0,sig);		sx = conv(x,y);		% truncate smooting results	j = 1 + w : length(sx) - w;	z = sx(j);		% fix edge effects	v = ones(1,length(z));	v = conv(v,y);	v = v(j);	z = z ./ v;		if b(2) == 2		j = 1 + w : length(X(:,1)) - w;		Z = [X(j,1) z'];	else		Z = z;	end		%Z = Z * 1000;