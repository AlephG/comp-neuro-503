% 260807111

%% Part 1: Reverse correlation with a one-dimensional output

impulse = [0 0 0 1 0 0 0];
r_impulse = oned(impulse);
filter1 = (xcorr(r_impulse, impulse, 50))./(length(impulse)*var(impulse));
figure(1);
plot(filter1(51:end)); 
axis tight;
title('Impulse-recovered filter');

noise = -1 + (1+1)*rand(1, 1000);
resp = oned(noise);
figure(2);
plot(resp);
axis tight;
title("Neuron's response to noise");

filter2 = xcorr(resp, noise, 50); 
normalized_filter = filter2./(length(noise)*var(noise));
figure(3);
plot(normalized_filter(51:end));
axis tight;
title('Noise-recovered filter');

pred = conv(normalized_filter(51:end), noise);

figure(4);
plot(resp);
hold on;
plot(pred);
legend("Observed", "Predicted");
title("Observed response vs Predicted response");

l = 1;
for input_length=[100 500 1000 2000 5000]
    cur_mse = 0;
    cur_mse_nl = 0;
    for y=1:25
        random_impulse = -1 + (1+1)*rand(1, input_length);
        actual_r = oned(random_impulse);
        predicted_r = conv(normalized_filter(51:end), random_impulse);
        nl_predicted_r = 100./(1 + exp(0.2*(26-predicted_r)));
        cur_mse = cur_mse + mean((predicted_r - actual_r).^2);
        cur_mse_nl = cur_mse_nl + mean((nl_predicted_r - actual_r).^2);
    end
    mse(l) = cur_mse./25;
    mse_nl(l) = cur_mse_nl./25;
    l = l+1;
end

figure(5);
b1 = bar(input_length, mse, 'FaceColor', [0 0.4470 0.7410]);
hold on;
b2 = bar(input_length, mse_nl, 'FaceColor', [0.8500 0.3250 0.0980]);
legend([b1(1);b2(1)], 'Linear MSE', 'Non-Linear MSE');
xlabel('Number of stimuli');
ylabel('MSE');
hold off;


%% Part 2: Spike-triggered averaging with three-dimensional input

threed_stimulus = -1 + 2*rand(20, 20, 12000);
threed_resp = threed(threed_stimulus);

sp_ind = find(threed_resp);
[dontcare, peak] = max(normalized_filter(51:end));
[dontcare, trough] = min(normalized_filter(51:end));


% Computing temporal responses
spatial_resp = zeros(20, 20, 2);
t =1;
for tau = [peak trough]
    avg_img = zeros(20, 20);
    for l=1:length(sp_ind)
        if ((sp_ind(l) - tau) <= 12000 && (sp_ind(l) - tau) > 0)
            avg_img = avg_img + threed_stimulus(:,:, (sp_ind(l) - tau));
        end
    end
    spatial_resp(:,:, t) = avg_img./length(sp_ind);
    t = t+1;
end

figure(6); imagesc(spatial_resp(:,:, 1)); colorbar;
title('Spatial Receptive Field of Temporal Response Peak');
figure(7); imagesc(spatial_resp(:,:, 2)); colorbar;
title('Spatial Receptive Field of Temporal Response Through');
