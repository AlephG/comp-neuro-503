function iSingleActivatingChannel

 %  load variables
    data = load('UnknownCurrent.mat');
    vStepvals = data.vStep;
    t = data.t;
    unknown = data.iUnknownCurrent;
    

 %  model parameters
    ba = .15;
    bi = -.11;
    v0a = -35; %35
    v0i = -45; %45
    gBar = 4; % mS
    Er = -65; % mV
    taua = 3; %msec
    taui = 5; %msec
    
    % plot steady state activation
    figure(1);
    clf;
    
    subplot(6,2,1);
    v1 = -80 : 20;
    v2 = -80 : 20;
    v3 = -80 : 20;
    v4 = -80 : 20;
    v5 = -80 : 20;
    plot(v1, twoParamSig(v1, [ba v0a]), 'LineWidth', 1.5);
    hold on;
    plot(v1, twoParamSig(v1, [bi, v0i]), 'LineWidth', 1.5);
    xlabel('mV');
    legend('xa(t = inf)', 'xi(t=inf)', 'Location', 'E');
    title('Example outward current');
    
    % plot parameters
    subplot(6,2,2);
    set(gca, 'Visible', 'off');
    text(0,0,['ba = ' num2str(ba)]);
    text(0,1,['v0a = ' num2str(v0a) ' mV']);
    text(0,2,['v0i = ' num2str(v0i) ' mV']);
    text(0,3,['taua = ' num2str(taua) ' msec']);
    text(2,2,['taui = ' num2str(taui) ' msec']);
    text(2,1,['Er = ' num2str(Er) ' mV']);
    text(2,0,['gBar = ' num2str(gBar) ' mS']);
    text(2,3,['bi = ' num2str(ba)]);
    
    ylim([0 6]);
    xlim([0 4]);    
    
    
    % run step
    vHold = -60;
    stepLength = 50;
    holdLength = 10;
    
    tStop = holdLength + stepLength + stepLength;

    dt = .25;
    
    ea = 1 - exp(-dt/taua);
    
    ei = 1 - exp(-dt/taui); %ei for inactivating variable
    
    tt = 0;
    j = 1;
       
    while tt <= tStop
        
        % update voltage
        if tt <= holdLength
            v1(j) = vHold;
            v2(j) = vHold;
            v3(j) = vHold;
            v4(j) = vHold;
            v5(j) = vHold;
        elseif tt > holdLength && tt <= holdLength + stepLength
            v1(j) = vStepvals(j, 1);
            v2(j) = vStepvals(j, 2);
            v3(j) = vStepvals(j, 3);
            v4(j) = vStepvals(j, 4);
            v5(j) = vStepvals(j, 5);
        else
            v1(j) = vHold;
            v2(j) = vHold;
            v3(j) = vHold;
            v4(j) = vHold;
            v5(j) = vHold;
            
        end
        
        % update activation variable xa
        xa1Inf = twoParamSig(v1(j), [ba v0a]);
        xa2Inf = twoParamSig(v2(j), [ba v0a]);
        xa3Inf = twoParamSig(v3(j), [ba v0a]);
        xa4Inf = twoParamSig(v4(j), [ba v0a]);
        xa5Inf = twoParamSig(v5(j), [ba v0a]);
        if j > 1
            xa1(j) = xa1(j-1) + (xa1Inf - xa1(j-1)) * ea;
            xa2(j) = xa2(j-1) + (xa2Inf - xa2(j-1)) * ea;
            xa3(j) = xa3(j-1) + (xa3Inf - xa3(j-1)) * ea;
            xa4(j) = xa4(j-1) + (xa4Inf - xa4(j-1)) * ea;
            xa5(j) = xa5(j-1) + (xa5Inf - xa5(j-1)) * ea;
        else
            xa1(j) = xa1Inf;
            xa2(j) = xa2Inf;
            xa3(j) = xa3Inf;
            xa4(j) = xa4Inf;
            xa5(j) = xa5Inf;
        end
        
        % update inactivation variable xi
        xi1Inf = twoParamSig(v1(j), [bi v0i]);
        xi2Inf = twoParamSig(v2(j), [bi v0i]);
        xi3Inf = twoParamSig(v3(j), [bi v0i]);
        xi4Inf = twoParamSig(v4(j), [bi v0i]);
        xi5Inf = twoParamSig(v5(j), [bi v0i]);
        if j > 1
            xi1(j) = xi1(j-1) + (xi1Inf - xi1(j-1)) * ei;
            xi2(j) = xi2(j-1) + (xi2Inf - xi2(j-1)) * ei;
            xi3(j) = xi3(j-1) + (xi3Inf - xi3(j-1)) * ei;
            xi4(j) = xi4(j-1) + (xi4Inf - xi4(j-1)) * ei;
            xi5(j) = xi5(j-1) + (xi5Inf - xi5(j-1)) * ei;
        else
            xi1(j) = xi1Inf;
            xi2(j) = xi2Inf;
            xi3(j) = xi3Inf;
            xi4(j) = xi4Inf;
            xi5(j) = xi5Inf;
        end
        
        % update conductance,current and time
        g1(j) = gBar * (xa1(j).^3) * xi1(j);
        g2(j) = gBar * (xa2(j).^3) * xi2(j);
        g3(j) = gBar * (xa3(j).^3) * xi3(j);
        g4(j) = gBar * (xa4(j).^3) * xi4(j);
        g5(j) = gBar * (xa5(j).^3) * xi5(j);

        i1(j) = (g1(j) * (v1(j) - Er))*.001; 
        i2(j) = (g2(j) * (v2(j) - Er))*.001;
        i3(j) = (g3(j) * (v3(j) - Er))*.001; 
        i4(j) = (g4(j) * (v4(j) - Er))*.001;
        i5(j) = (g5(j) * (v5(j) - Er))*.001;
        
        tt = tt + dt;
        j = j + 1;
    end
    
    % plot time course
    subplot(6,1,2);
    plot(t,v1, 'LineWidth', 1.5);
    hold on;
    plot(t,v2, 'LineWidth', 1.5);
    hold on;
    plot(t,v3, 'LineWidth', 1.5);
    hold on;
    plot(t,v4, 'LineWidth', 1.5);
    hold on;
    plot(t,v5, 'LineWidth', 1.5);
    axis tight;
    ylabel('V step (mV)');
    
    subplot(6,1,3);
    plot(t, xa1, 'LineWidth', 1.5);
    hold on;
    plot(t, xa2, 'LineWidth', 1.5);
    hold on;
    plot(t, xa3, 'LineWidth', 1.5);
    hold on;
    plot(t, xa4, 'LineWidth', 1.5);
    hold on;
    plot(t, xa5, 'LineWidth', 1.5);
    axis tight;
    ylabel('xa');
    
     subplot(6,1,4);
    plot(t, xi1, 'LineWidth', 1.5);
    hold on;
    plot(t, xi2, 'LineWidth', 1.5);
    hold on;
    plot(t, xi3, 'LineWidth', 1.5);
    hold on;
    plot(t, xi4, 'LineWidth', 1.5);
    hold on;
    plot(t, xi5, 'LineWidth', 1.5);
    axis tight;
    ylabel('xi');
   
    subplot(6,1,5);
    plot(t, (g1), 'LineWidth', 1.5);
    hold on;
    plot(t, (g2), 'LineWidth', 1.5);
    hold on;
    plot(t, (g3), 'LineWidth', 1.5);
    hold on;
    plot(t, (g4), 'LineWidth', 1.5);
    hold on;
    plot(t, (g5), 'LineWidth', 1.5);
    axis tight;
    ylabel('g (mS)');
    ylim([0 inf]);
    
    subplot(6,1,6);
    plot(t, unknown, '--', 'LineWidth', 1.5);
    hold on;
    plot(t, i1, 'Color', [0 0.4470 0.7410], 'LineWidth', 1.5);
    hold on;
    plot(t, i2, 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 1.5);
    hold on;
    plot(t, i3, 'Color', [0.9290 0.6940 0.1250], 'LineWidth', 1.5);
    hold on;
    plot(t, i4, 'Color', [0.4940 0.1840 0.5560], 'LineWidth', 1.5);
    hold on; 
    plot(t, i5, 'Color', [0.4660 0.6740 0.1880], 'LineWidth', 1.5);
    axis tight;
    xlabel('msec');
    ylabel('i (mA)');
    ylim([-inf inf]);
end
