function [ vG ] = CalcFunGrad( vX, hObjFun, diffMode, epsVal )
% ----------------------------------------------------------------------------------------------- %
% [ vG ] = CalcFunGrad( vX, hObjFun, difMode, epsVal )
%   Calculating the Gradient Vector of a function using Finite Differences
%   method.
% Input:
%   - vX            -   Input Vector.
%                       The point the gradient is calculated at.
%                       Structure: Vector (Column).
%                       Type: 'Single' / 'Double'.
%                       Range: (-inf, inf).
%   - hObjFun       -   Objective Function.
%                       Function handler which evaluates the Objective
%                       Function at a given point - hObjFun(vX).
%                       Structure: Function Handler.
%                       Type: Function Handler.
%                       Range: NA.
%   - diffMode      -   Difference Mode.
%                       Sets the mode of operation of the Finite
%                       Differences Method - Forward, Backward, Central or
%                       Complex.
%                       Structure: Scalar.
%                       Type: 'Single' / 'Double'.
%                       Range: {1, 2, 3, 4}.
% Output:
%   - vG            -   Gradient Vector.
%                       The numerical approximation of the gradient of the
%                       Objective Function at the input point 'vX'.
%                       Structure: Vector (Column).
%                       Type: 'Single' / 'Double'.
%                       Range: (-inf, inf).
% References
%   1.  https://en.wikipedia.org/wiki/Finite_difference_coefficient.
%   2.  Nick Higham Talk (https://www.youtube.com/watch?v=Q9OLOqEhc64) At 02:15.
%   3.  Complex Step Differentiation - https://blogs.mathworks.com/cleve/2013/10/14/complex-step-differentiation/.
%   4.  Complex Step Derivative - https://timvieira.github.io/blog/post/2014/08/07/complex-step-derivative/.
%   5.  The Complex Step Derivative Approximation - https://dl.acm.org/citation.cfm?id=838251.
% Remarks:
%   1.  Adapt `min()`, `max()`, `abs()` and `'` in the code to work
%       properly on complex numbers. Pay attention to all functions that
%       use `abs()` implictly (For instance, Norms).
% TODO:
%   1.  U.
% Release Notes:
%   -   1.2.000     22/07/2023  Royi Avital
%       *   Added `arguments` block.
%   -   1.1.001     24/06/2019  Royi Avital
%       *   Changed 'difMode' -> 'diffMode'.
%   -   1.1.000     22/08/2018  Royi Avital
%       *   Added Complex Mode.
%   -   1.0.001     13/06/2018  Royi Avital
%       *   Small fixes for better readability.
%   -   1.0.000     08/07/2017  Royi Avital
%       *   First release version.
% ----------------------------------------------------------------------------------------------- %

arguments(Input)
    vX (:, 1) {mustBeNumeric, mustBeFinite, mustBeReal}
    hObjFun (1, 1) {mustBeA(hObjFun, 'function_handle')}
    diffMode (1, 1) {mustBeMember(diffMode, [1, 2, 3, 4])} = 4
    epsVal (1, 1) {mustBeNumeric, mustBeReal, mustBeFinite, mustBeFloat} = 1e-6
end

arguments(Output)
    vG (:, 1) {mustBeNumeric, mustBeFinite, mustBeReal}
end

FALSE   = 0;
TRUE    = 1;

OFF     = 0;
ON      = 1;

DIFF_MODE_FORWARD   = 1;
DIFF_MODE_BACKWARD  = 2;
DIFF_MODE_CENTRAL   = 3;
DIFF_MODE_COMPLEX   = 4;

numElements = size(vX, 1);

objFunRef   = hObjFun(vX);
vG          = zeros(numElements, 1);
vPertVal    = zeros(numElements, 1); %<! Perturbation

switch(diffMode)
    case(DIFF_MODE_FORWARD)
        hCalcGradFun = @(vPertVal) (hObjFun(vX + vPertVal) - objFunRef) / epsVal;
    case(DIFF_MODE_BACKWARD)
        hCalcGradFun = @(vPertVal) (objFunRef - hObjFun(vX - vPertVal)) / epsVal;
    case(DIFF_MODE_CENTRAL)
        hCalcGradFun = @(vPertVal) (hObjFun(vX + vPertVal) - hObjFun(vX - vPertVal)) / (2 * epsVal);
    case(DIFF_MODE_COMPLEX)
        hCalcGradFun = @(vPertVal) imag(hObjFun(vX + (1i * vPertVal))) / epsVal;
end

for ii = 1:numElements
    vPertVal(ii)    = epsVal;
    vG(ii)          = hCalcGradFun(vPertVal);
    vPertVal(ii)    = 0;
end


end

