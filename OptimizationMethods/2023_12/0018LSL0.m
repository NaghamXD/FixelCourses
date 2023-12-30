% Optimization Methods
% Convex Optimization - Non Smooth Optimization - Proximal Gradient Method
% Regularization of LS solution with the L0 **pseudo** norm.
% The model is given by:
% $$ arg min_x || A * x - y ||_2^2 + λ || x ||_∞ $$
% References:
%   1.  
% Remarks:
%   1.  B
% TODO:
% 	1.  C
% Release Notes Royi Avital RoyiAvital@yahoo.com
% - 1.0.000     30/12/2023
%   *   First release.


%% General Parameters

subStreamNumberDefault = 79;
% subStreamNumberDefault = 0;

run('InitScript.m');

figureIdx           = 0;
figureCounterSpec   = '%04d';

generateFigures = OFF;

%% Constants

DIFF_MODE_FORWARD   = 1;
DIFF_MODE_BACKWARD  = 2;
DIFF_MODE_CENTRAL   = 3;
DIFF_MODE_COMPLEX   = 4;

STEP_SIZE_MODE_CONSTANT     = 1;
STEP_SIZE_MODE_ADAPTIVE     = 2;
STEP_SIZE_MODE_LINE_SEARCH  = 3;


%% Parameters

% Data
numGridPts  = 25;
polyDeg     = 5; %<! Polynomial Degree
numFeatures = 3;
noiseStd    = 0.085;

% Model
paramLambda = 0.075; %<! 0.1595

% Solver
numIterations   = 5000;
stepSize        = 0.0075;

% Verification
diffMode    = DIFF_MODE_CENTRAL;
errTol      = 1e-5;

% Visualization
vLim = [0; 1];


%% Generate / Load Data

% Building a sparse model of the data.
% The feature space is a polynomial. The data is generated using a sub set
% of features which are not zero.

vA = sort(rand(numGridPts, 1), 'ascend'); %<! Grid
mA = vA .^ (0:polyDeg); %<! Model Matrix

vXRef           = zeros(polyDeg + 1, 1);
vFeatIdx        = randperm(polyDeg + 1, numFeatures);
vXRef(vFeatIdx) = randn(numFeatures, 1); %<! Active features

vN = noiseStd * randn(numGridPts, 1); %<! Noise Samples
vS = mA * vXRef;
vY = vS + vN;

mX = zeros(polyDeg + 1, numIterations);


% Analysis
vObjVal = zeros(numIterations, 1);

hObjFun = @(vX, paramLambda) 0.5 * sum((mA * vX - vY) .^ 2) + paramLambda * sum(vX ~= 0);


%% Display the Data

figureIdx = figureIdx + 1;

hF = figure('Position', figPosLarge);
hA = axes(hF);
set(hA, 'NextPlot', 'add');
hLineObj = line(vA, vS, 'DisplayName', 'Model Data');
set(hLineObj, 'LineWidth', lineWidthNormal);
hLineObj = line(vA, vY, 'DisplayName', 'Data Samples');
set(hLineObj, 'LineStyle', 'none', 'Marker', '*');

set(hA, 'XLim', vLim);
set(get(hA, 'Title'), 'String', {['Model Data and Noisy Samples']}, 'FontSize', fontSizeTitle);
set(get(hA, 'XLabel'), 'String', {['x']}, 'FontSize', fontSizeAxis);
set(get(hA, 'YLabel'), 'String', {['y']}, 'FontSize', fontSizeAxis, 'Interpreter', 'latex');

hLegend = ClickableLegend();

if(generateFigures == ON)
    print(hF, ['Figure', num2str(figureIdx, figureCounterSpec), '.png'], '-dpng', '-r0'); %<! Saves as Screen Resolution
end


%% Least Squares Solution
% 1. Calculate the Linear Least Sqaures solution.

%----------------------------<Fill This>----------------------------%
vXLs = mA \ vY;
%-------------------------------------------------------------------%


%% Set Auxiliary Functions
% 1. Set `hGradFun = @(vX) ...` to calculate the gradient of f(x).
% 2. Set `hProxFun = @(vY, paramLambda) ...` to calculate the proximal operator of g(x).
%    You may use the function `ProjectL1Ball(vY, ballRadius)`.
% 3. Run this section to verify your implementation.
%    It won't verify the ``hProxFun`. Why?

%----------------------------<Fill This>----------------------------%
hGradFun = @(vX) mA.' * (mA * vX - vY);
hProxFun = @(vY, paramLambda) (abs(vY) > sqrt(2 * paramLambda)) .* vY; %<! L0 Prox
%-------------------------------------------------------------------%

vX = randn(polyDeg + 1, 1);

vG = CalcFunGrad(vX, @(vX) 0.5 * sum((mA * vX - vY) .^ 2), diffMode);
assertCond = norm(hGradFun(vX) - vG, 'inf') <= (errTol * norm(vG));
assert(assertCond, 'The Gradient Operator calculation deviation exceeds the threshold %f', errTol);
disp(['The Gradient Operator implementation is verified']);

disp(['The Prox Operator can not be verified. Why?']);


%% PGD / PGM Solution

mX = ProxGradientDescent(mX, hGradFun, hProxFun, stepSize, paramLambda);

disp(['The PGD solution can not be verified. Why?']);


%% Display Results

figureIdx = figureIdx + 1;

hF = figure('Position', figPosLarge);
hA = axes(hF);
set(hA, 'NextPlot', 'add');
hLineObj = line(vA, vS, 'DisplayName', 'Model Data');
set(hLineObj, 'LineWidth', lineWidthNormal);
hLineObj = line(vA, vY, 'DisplayName', 'Data Samples');
set(hLineObj, 'LineStyle', 'none', 'Marker', '*');
hLineObj = line(vA, mA * vXLs, 'DisplayName', 'Least Squares');
set(hLineObj, 'LineWidth', lineWidthNormal);
hLineObj = line(vA, mA * mX(:, end), 'DisplayName', 'L0 Regularized Least Squares');
set(hLineObj, 'LineWidth', lineWidthNormal);

set(hA, 'XLim', vLim);
set(get(hA, 'Title'), 'String', {['Estimation from Data Samples']}, 'FontSize', fontSizeTitle);
set(get(hA, 'XLabel'), 'String', {['x']}, 'FontSize', fontSizeAxis);
set(get(hA, 'YLabel'), 'String', {['y']}, 'FontSize', fontSizeAxis);

hLegend = ClickableLegend();

if(generateFigures == ON)
    print(hF, ['Figure', num2str(figureIdx, figureCounterSpec), '.png'], '-dpng', '-r0'); %<! Saves as Screen Resolution
end

mX(:, end)

%?%?%?
% - How can you verify the step size?
% - Look at the values of `vXLs` vs. `mX(:, end)`. Are they different? Why?


%% Auxiliary Functions


%% Restore Defaults

% set(0, 'DefaultFigureWindowStyle', 'normal');
% set(0, 'DefaultAxesLooseInset', defaultLoosInset);

