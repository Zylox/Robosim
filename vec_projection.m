## Copyright (C) 2013 Her Majesty The Queen In Right of Canada
## Developed by Defence Research & Development Canada 
##
## This file is part of Octave.
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {Function File} {} vec_projection (@var{x}, @var{y})
## Compute the vector projection one 3-vector onto another.
## @var{x} : size 1 x 3 and @var{y} : size 1 x 3 @var{tol} : size 1 x 1 
##
## @example
## @group
## vec_projection ([1,0,0], [0.5,0.5,0])
##      @result{} 0.70711
## @end group
## @end example
##
## Vector projection of @var{x} onto @var{y}, both are 3-vectors, 
## returning the value of @var{x} along @var{y}. Function uses dot product,  
## Euclidean norm, and angle between vectors to compute the proper length along 
## @var{y}. 
## @end deftypefn
## Author: DRE 2013 <David.Erickson@drdc-rddc.gc.ca>
## Created: 10 June 2013
function out = vec_projection (x, y, tol)
%% Error handling
if (size(x,1)!=1 && size(x,2)!=3)
 out = -1
 warning ("vec_projection: first vector is not 1x3 3-vector");
endif
if (size(y,1)!=1 && size(y,2)!=3)
 out = -1
 warning ("vec_projection: second vector is not 1x3 3-vector");
endif
%% Compute Dot Product Method: proj(x,y) = |x|*cos(theta)
dp  =  dot (x,y);
%% Compute Angle Between X and Y
theta  = dp / (norm(x,2) * norm(y,2));
theta  = acos(theta);
%%theta_d = 360/(2*pi) *(theta)%% for viewing
%% Compute X Projected onto Y Unit Vector
temp =  norm(x,2) *(cos(theta));
%% validate with third argument if needed
if (nargin == 3)
   %% Alternate Solution proj(x,y) = x * y/norm(y,2)
   %% Compute Y Unit Vector
   unit_y = y / (norm(y,2));%% Euclidean 2-norm
   temp2 = dot(x,unit_y);
   if (temp2 - temp <= tol)
   	out = temp;
   else
 	out = -1;
        warning ("vec_projection: Warning, vector projection exceeded tolerance");
   endif
endif
%% Final Stage output
out = temp;
endfunction
%!test
%! assert(vec_projection([1,0,0], [0.5,0.5,0])==0.70711);
%! assert(vec_projection([1,2000,0],[0.5,15,0])==1998.9);
%! assert(vec_projection([1,-2000,0],[0.5,15,0])==-1998.9);
%! assert(vec_projection([7,7,0],[15,0,0]])==7.000);
%! assert(vec_projection([1,1,0],[1.05,0.94,0])])==1.4121);
%! assert(vec_projection([1,1.1,0],[1.05,0.94,0])])==1.4788);

