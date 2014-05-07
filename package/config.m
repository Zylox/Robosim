%%%starting energy. everyone starts with same energy
energy.startingEnergy = 10000;
%%%energy costs for various actions
energy.moveEnergyCost = 1;
energy.turnEnergyCost = 1;
energy.turnSensorEnergyCost = 1;
energy.sensingEnergyCost = 1;

%%%standard deviations for actions randomness
sigma.movementSigma = .1;
sigma.turningSigma = .1;
sigma.turningSensorSigma = .1;
sigma.sensingSigma = 0;

%%%means for actions randomness
mu.movementMu = 0;
mu.turningMu = 0;
mu.turningSensorMu = 0;
mu.sensingMu = 0;

%%%how much each of these actions move in one step
perStep.move = 1;
perStep.turn = 1;
perStep.sensorTurn = 1;

%%%Simulation time (not real time
time = 100000;
timeStep = 10;   %% how much time each step represents
botRadius = 20;	 %% radius of bots

%%%any default command line arguments
%ex deafultCommandLineArgs = "-rs -norand -b zachbot.m"
% these are added to the ones you input on command line arguments, at the end.
% if you specify a map in here, you have to specify the bots here too due to order constraints
defaultCommandLineArgs = "";