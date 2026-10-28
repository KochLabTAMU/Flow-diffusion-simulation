%parpool('Threads')

simulationLength = 1000;    % in seconds
%particleConcentration = [1, 4, 8, 12, 16, 32, 64] * 1e-13;
particleConcentration = 10e-12;
    % MW Gent = 478g/mol
    % 50ug/ml = 105uM
%flowRate = 0.01;
flowRate = 3;
%extinctionRatio = [10, 20, 30, 40, 50, 60, 80, 100, 120, 160, 200];%2250;%300;
extinctionRatio = 1 * [10,100,1000]; %[3, 10, 30, 100, 300, 1000, 3000]
particleDiameter = 0.9 * 1e-9; 

output = {[1,1]};
parfor i = 1:length(extinctionRatio)
    output(i) = {flowSim(simulationLength, particleConcentration, flowRate, extinctionRatio(i), particleDiameter)};
end
saveFlowSims(output, 'Gent_conc10e12_flow3_pD03_1-5_5_extRat_10_100_1000_t0_01_T1000')

function saveFlowSims(data, fileStr)
    for i = 1 : length(data)
        writematrix([data{i}(:,1), data{i}(:,2)], append(fileStr, '_', num2str(i)))
    end
end