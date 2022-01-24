function y = twoParamSig(x, params)

    b = params(1);
	x0 = params(2);
	
	y = 1 ./ (1 + exp(-b .* (x - x0)));
end