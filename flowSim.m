function outXY = flowSim(T, H2O2concentration, flowRate, extinctionRatio, particleDiameter)
    %% PARAMETERS THAT DEFINE THE EXPERIMENT
    
    channelLength = 30e-2;%105e-2;
    channelWidth = 500e-6;
    channelHeight = 50e-6;
    %flowRate = 10;    % in ul/min
    % Molar concentration of H2O2 particles that are flushed into the channel
    %H2O2concentration = 8e-13;                                          
    %flowRate = 10;
    
    %% PARAMETERS THAT DEFINE the SIMULATION
    
    dt = 0.01;         % time step for simulation
    %T = 1;            % Total simulation length in seconds
    tUpdate = 0.01;     % Time interval that plot is updated and data stored for analysis.
    currTimeStep = 0;   % Used as a parameter tflowSImffffffffaSDFadfADFsdfhat is counted up for each time step during simulation.
    
    
    %% PARAMETERS THAT ARE NEEDED FOR COMPOUTATiON DURING THE SIMUALTION
    
    % Calculates the flow velocity in the center of teh channel in m/s
    v0 = 3 / 2 / channelHeight / channelWidth * 1.7e-11 * flowRate; 
    
    % Calculate the number of particles per cubic meter from Molar concentration.
    H2O2particleConcentration = H2O2concentration * 6.022e23 * 1000;   
    
    % Calculate the number of total particles in the channel at the beginning
    % of the experiment.
    H2O2particlesInChannel = fix(H2O2particleConcentration * channelHeight * channelWidth * channelLength);
    
    % Calculate the distance that the flow travels during each interval. At the
    % beginning of the channel, all molecules within thsi distance will have
    % traveled downstream. Hence, this area needs to be "refilled" with
    % aprticles because in the experiment, they would come with the new liquid.
    flowLength = flowRate * 1e-6 * 1e-3 / 60 / channelWidth / channelHeight * dt;   
    
    % Calculate the number of particles that is in the channel in this
    % distance.
    H2O2particlesFlowLength = fix(H2O2particleConcentration * flowLength * channelWidth * channelHeight);
    
    % The diameter of the particle
    % particleDiameter = 0.1e-9;  
    %  The viscosity of water
    viscosityWater = 1e-3;  
    % The visocus drag of a particle in water
    drag = 3 * pi * particleDiameter * viscosityWater;  
    
    temperature = 303;  % in Kelvin
    kBT = temperature * 1.38e-23;
    
    
    %% INITIALIZE THE SIMULATION
    
    % Seed the channel with particles at random positions.
    xPos = rand(H2O2particlesInChannel, 1) * channelLength;
    yPos = rand(H2O2particlesInChannel, 1) * channelHeight;
    
    % Plotting the data
    %plotEveryNthParticle = 1000;
    %h = scatter(xPos(1 : plotEveryNthParticle : end), yPos(1 : plotEveryNthParticle : end), 'Or');
    %xlim([-0.2 * channelLength 1.2 * channelLength])
    %ylim([-0.1 * channelHeight 1.1 * channelHeight])
    
    
    %% RUN THE ACTUAL SIMULATION
    
    % Update particle positions during simulation
    %a = datetime('now');    % Store the time of the beginnign of the simulation
                            % for performance evaluation
    particelsToRemove = []; % Need to initialize here
    j = 0;                  % Need to initialize here
    while currTimeStep < T
        
    
        % During each iteration, count up the current time by the time increment dt.
        currTimeStep = currTimeStep + dt;
        % Calculate the flow velovity that each particle in the channel
        % experiences.
        v = v0 * (1 - ((yPos - channelHeight/2) / (channelHeight / 2)).*((yPos - channelHeight/2) / (channelHeight / 2)));
        % Calculate the new x position of each particle considering the flow of
        % particles and their Brownian diffusion.
        xPos = xPos + dt * v + dt * (1 / drag * (rand(length(xPos), 1) - 0.5)) * sqrt(24 * drag * kBT / dt);
        % Calculate the new y position of each particle considering their
        % Brownian diffusion (flow only goe in x direction).
        yPos = yPos + dt / drag * (rand(length(xPos), 1) - 0.5) * sqrt(24 * drag * kBT / dt);
    
        %Make sure particles cannot diffsue past the lower and upper channel boundaries
        for i = 1:length(xPos)
            % Particles bounce off of coverslip or are extinguished by a cell
            if yPos(i) < 0
                if j >= extinctionRatio & xPos(i) > 0.04
                    j = 0;
                    particelsToRemove = [particelsToRemove i];
                elseif xPos(i) > 0.02
                    j = j + 1;
                    yPos(i) = -yPos(i);
                else
                    yPos(i) = -yPos(i);
                end
            end
            
            % Particles bounce off of channel ceiling
            if yPos(i) > channelHeight
                yPos(i) = channelHeight - (yPos(i) - channelHeight);
            end
        end
        
        xPos(particelsToRemove) = []; % This removes all necessary particles from xPos
        yPos(particelsToRemove) = []; % This removes all necessary particles from yPos
        particelsToRemove = [];
        
        % Make sure particels that are flushed out of the channel are removed
        % from out lists of particle positions
        particelsToRemove = zeros(1,H2O2particlesFlowLength);
        k = 1;
        for i = 1:length(xPos)
            % Create list of particles that are flushed out of the channel
            if xPos(i) > channelLength
                if k <= length(particelsToRemove)
                    particelsToRemove(k) = i;
                else
                    particelsToRemove = [particelsToRemove i];
                end
                k = k + 1;
            end
        end
        if k <= length(particelsToRemove)
            particelsToRemove(k:end) = [];
        end
        % Remove the particles that were identified as flushed out of the
        % channel from the list of particles
        xPos(particelsToRemove) = []; % This removes all necessary particles from xPos
        yPos(particelsToRemove) = []; % This removes all necessary particles from yPos
        particelsToRemove = [];
        % Seed new particles in the beginnign of the channel, becasue the
        % particles that were there before the simulation step have moved to
        % the right during the above simulation step.
        xPosNewParticles = rand(H2O2particlesFlowLength, 1) * flowLength;
        yPosNewParticles = rand(H2O2particlesFlowLength, 1) * channelHeight;
        % "Attach" the list of these particles to the other list of particles
        xPos = cat(1, xPosNewParticles, xPos); % cat means concatenate
        yPos = cat(1, yPosNewParticles, yPos);
    
        % Update the plot whenever the time tUpdate has elasped
        %if mod(fix(currTimeStep*10000), fix(tUpdate*10000)) == 0    % Fix is needed to get proper integer values for mod function)
        %    set(h, 'xData', xPos(1 : plotEveryNthParticle : end), 'yData', yPos(1 : plotEveryNthParticle : end));
        %    drawnow
        %end
        
    end
    % Calculate how long the simulation was running in seconds.
    % datetime('now') - a
    outXY = [xPos, yPos];
    %outX = xPos;
    %outY = yPos;
end