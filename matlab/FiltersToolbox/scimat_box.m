function box = scimat_box(scimat, m, a)
% SCIMAT_BOX  Compute tight box around SCIMAT segmentation.
%
% X = scimat_box(SCIMAT, M, A)
%
%   This function finds the vertices of a box tangent to the edges of a
%   segmentation. The box can be vertical or have any other orientation.
%
%   SCIMAT is a struct with the segmentation (see "help scimat" for
%   details).
%
%   X is a (3, 8)-matrix with the coordinates of the box vertices.
%
%   M is a 3-vector with the coordinates of the rotation centre. By
%   default, M=[0 0 0].
%
%   A is a (3, 3)-rotation matrix, in case the data has to be rotated
%   before computing the box. By default, A is the identity matrix and no
%   rotation is performed. To be consistent with the ITK (Insight Toolkit)
%   convention, the A matrix has to be the "backwards transformation", i.e.
%   A is the rotation from output to input voxel coordinates.
%
%   The "backwards transformation" is the transpose of the forward
%   transformation.

% Author: Ramon Casero <rcasero@gmail.com>
% Copyright © 2010,2014 University of Oxford
% Version: 0.2.1
% 
% University of Oxford means the Chancellor, Masters and Scholars of
% the University of Oxford, having an administrative office at
% Wellington Square, Oxford OX1 2JD, UK. 
%
% This file is part of Gerardus.
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details. The offer of this
% program under the terms of the License is subject to the License
% being interpreted in accordance with English Law and subject to any
% action against the University of Oxford being under the jurisdiction
% of the English Courts.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

% check arguments
narginchk(1, 3);
nargoutchk(0, 1);

% default
if (nargin < 2 || isempty(m))
    m = [0 0 0];
end
if (nargin < 3 || isempty(a))
    a = eye(3); % identity matrix
end

% remove the dummy dimension
scimat = scimat_squeeze(scimat);

% get hold of all the points in the segmentation mask

% extract linear indices of voxels in the segmentation
idx = find(scimat.data);

% get volume size
sz = size(scimat.data);

% convert linear index to multiple subscripts
[ir, ic, iz] = ind2sub(sz, idx);

% convert indices to real world coordinates and make column vectors
x = scimat_index2world([ir, ic, iz], scimat)';

% to make the interface consistent, we ask the user to input the backwards
% rotation (whenever we input the scimat volume, backwards rotation;
% whenever we input points, forwards rotation). But actually, we are going
% to operate on points, so we need to get the forwards rotation
a = a';

% avoid unnecessary operations if rotation is identity matrix
if all(all(a ~= eye(3)))
    
    % move points to centre of rotation
    for I = 1:3
        x(I, :) = x(I, :) - m(I);
    end
    
    % rotate real world coordinates
    x = a * x;
    
end

% find the limits of the data
minx = min(x, [], 2);
maxx = max(x, [], 2);

% create the box vertices
box = [...
    minx ...
    [minx(1) maxx(2) minx(3)]' ...
    [maxx(1) maxx(2) minx(3)]' ...
    [maxx(1) minx(2) minx(3)]' ...
    [minx(1) minx(2) maxx(3)]' ...
    [minx(1) maxx(2) maxx(3)]' ...
    maxx ...
    [maxx(1) minx(2) maxx(3)]' ];


if all(all(a ~= eye(3)))
    
    % undo rotation of vertices
    box = a' * box;
    
    % move vertices back from centre of rotation
    for I = 1:3
        box(I, :) = box(I, :) + m(I);
    end
end
