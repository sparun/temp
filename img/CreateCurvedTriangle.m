% CreateCurvedTriangle --> Create a curved triangle image
% T = CreateCurvedTriangle(b,p,c)
% Required inputs
%    p             = pointiness of the triangle (always > 0.5)
%    c             = curvature between [-1 1] (positive is convex, negative is concave)
% Outputs:
%    T             = BW image of the triangle stimulus
% References
%    For details of creation see page 13 of 
%    Vighneshvel T & Arun SP (2013) Does linear separability really matter? 
%    Complex search is explained by simple search. Journal of Vision, 13(11):10, 1-24
%
% Examples
%    T = CreateCurvedTriangle(10,1,-0.5); % creates a curved triangle
%    CurvedTriangleSpace.jpg shows the full parametric space
%    CreateCurvedTriangleMatrix creates equally spaced triangle stimuli 

% ChangeLog: 
%    01/01/2011 - SPA/TV - first version
%    11/10/2017 - SPA    - welcomed into lib

function T = CreateCurvedTriangle(p,c)
if(abs(c) > 1), error('Curvature is too large'); end;
if(p <= 0.5), error('Triangle cannot be formed'); end;

b = 10; % default base width (not relevant to change) 
c_inverse = abs(1/c);
s = p * b; % side of the concave/concave triangle.
r1 = s * c_inverse * p; % radii of two sides (left and right).
r2 = b * c_inverse; % radius of the base.
h = sqrt (s^2 - (b/2)^2); % height of the triangle.

%  define the triangle
x1 = 0:0.01:b/2; y1 = (x1*h)/(b/2); % left side
x2 = b/2:0.001:b; y2 = (-h* (x2 - b/2))/(b- (b/2)) + h; % right side
x3 = 0:0.001:b; y3 = zeros(size(x3)); % base

% Define left curve (concave)
t1 = acos((b/2)/s); % theta 1.
t2 = acos((s/2)/r1); % theta 2.
t3 = pi - t1 - t2; % theta 3.
b4 = r1*sin(t3); a4 = -r1*cos(t3); % a4 and b4 are the co-ordinates of the centre of the circle.
x4 = 0:0.01:b/2;
y4 = b4 - sqrt(r1^2-(x4-a4).^2); qimag = find(y4~=real(y4));
y4(qimag) = b4 - sqrt(r1^2 - (x4(qimag)-a4).^2);

% Define right curve (concave)
t4 = asin (h/s); % theta 4.
t5 = acos ((s/2)/r1); % theta 5.
t6 = pi - t4 - t5; % theta 6.
a5 = r1 * cos (t6) + b; b5 = r1 * sin (t6); % a5 and b5 are the co-ordinates of the centre of the circle.
x5 = b/2:0.01:b;
y5 = b5 - sqrt(r1^2-(x5-a5).^2); qimag = find(y5~=real(y5));
y5(qimag) = b5 + sqrt(r1^2 - (x5(qimag)-a5).^2);

% Define bottom curve (concave)
a6 = b/2; b6 = - sqrt ((r2)^2 - (b/2)^2); % a6 and b6 are the co-ordinates of the centre of the circle.
x6 = 0:0.1:b; y6 = b6 + sqrt (r2^2 - (x6 - a6).^2);

% Define left curve (convex)
a7 = r1*cos(t3)+ b/2; b7 = 2*(h/2) - b5; % a7 and b7 are the co-ordinates of the centre of the circle.
x7 = 0:0.1:b/2;
y7 = b7 + sqrt(r1^2-(x7-a7).^2); qimag = find(y7~=real(y7));
y7(qimag)= b7 + sqrt(r1^2 - (x7(qimag)-a7).^2);

% Define right curve (convex)
a8 = 2*(3*b/4)-a5; b8 = 2*(h/2)-b5; % a8 and b8 are the co-ordinates of the centre of the circle.
x8 = b/2:0.01:b;
y8 = b8 + sqrt(r1.^2-(x8-a8).^2); qimag = find(y8~=real(y8));
y8(qimag) = b8 + sqrt(r1.^2 - (x8(qimag)-a8).^2);

% Define bottom curve (convex)
a9 = b/2; b9 = sqrt ((r2)^2 - (b/2)^2); % a9 and b9 are the co-ordinates of the centre of the circle.
x9 = 0:0.1:b; y9 = b9 - sqrt (r2^2 - (x9 - a9).^2);

% plot filled shape
if(c==0)
    fill([x1 x2 x3],[y1 y2 y3],'k'); % fills the 2D space.
elseif(c<0)
    x = [x4 x5 fliplr(x6)]; y = [y4 y5 fliplr(y6)];
    fill(x,y,'k'); % fills the 2D space.
elseif(c>0)
    fill([x7 x8 fliplr(x9)],[y7 y8 fliplr(y9)],'k');
end
axis off; axis equal; 
saveas(gcf,'junk.tif'); 
T = imread('junk.tif'); T = mean(T,3); 
delete('junk.tif'); 
close(gcf); 

if(0) % turn on to plot outlines of all triangles
    figure; hold on; 
    plot(x1,y1,'c'); plot(x2, y2,'c'); plot (x3, y3,'c'); % Plots the triangle
    plot(x7,y7,'m'); plot(x8,y8,'m'); plot (x9,y9,'m'); % Plots the Convex triangle.
    plot(x4,y4,'b'); plot(x5,y5,'b'); plot(x6,y6,'b'); % Plots the Concave triangle   
end

return
