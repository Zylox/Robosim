energy.startingEnergy = 10000;
energy.moveEnergyCost = 1;
energy.turnEnergyCost = 1;
energy.turnSensorEnergyCost = 1;
energy.sensingEnergyCost = 1;

sigma.movementSigma = .1;
sigma.turningSigma = .1;
sigma.turningSensorSigma = .1;
sigma.sensingSigma = .1;

mu.movementMu = 0;
mu.turningMu = 0;
mu.turningSensorMu = 0;
mu.sensingMu = 0;

perStep.move = .5;
perStep.turn = 10;
perStep.sensorTurn = 1;

time = 10000;
timeStep = 10;
botRadius = 20;
defaultCommandLineArgs = "heloo world";