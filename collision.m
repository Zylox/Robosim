function collide = circleMapCollision(x,y,radius)
	%(x-a)^2 + (y-b)^2 - r^2 = 0
	%printf("%d %d %d\n", x,y, radius);
	
	global map;
	if(floor(x)-radius <=0 || floor(x)+radius > rows(map.map)+0 || floor(y)-radius <=0 || floor(y)+radius > columns(map.map)+0)
		collide = 1;
		
		debugDisp("corners info")
		debugDisp(ceil(y)+radius)
		debugDisp(columns(map.map))
		debugDisp(ceil(x)+radius)
		debugDisp(rows(map.map))
		
		return;
	endif

	
	corners = getRegionOfCorners(x-radius, y-radius , x+radius, y+radius);
	
	checkIt = 0;
	
	for(q = 1:4)
		checkIt += map.miniMap(corners(q,2),corners(q,1));
	endfor
	if(checkIt == 0)
		collide = 0;
		return;
	endif
	
	radiusSq = radius^2;
	collide = 0;

	for(i = floor(x)-radius:floor(x)+radius)
		if(i > map.dims(2))
			collide = 1;
			return;	
		endif
		for(j = floor(y)-radius:floor(y)+radius)
			if(j > map.dims(1))
					collide = 1;
					return;
			endif
			if(map.map(i,j) == 1)
				if(pixelCircleCollision(i,j,x,y,radius))
					collide = 1;
					return;
				endif
			endif
		endfor
	endfor
	
endfunction

function collide = pixelMapCollision(x, y)

	global map;
	if(floor(x) <=0 || floor(x)> rows(map.map) || floor(y) <=0 || floor(y) > columns(map.map))
		collide = 1;
		
		debugDisp("corners info")
		debugDisp(floor(y))
		debugDisp(columns(map.map))
		debugDisp(floor(x))
		debugDisp(rows(map.map))
		
		return;
	endif

	if(map.map(floor(x),floor(y)) == 1)
		collide = 1;
	else
		collide = 0;
	endif
	
endfunction

function collide = pixelCircleCollision(x,y, xc, yc, radius)
	distSq = (xc-x)^2 + (yc-y)^2;
	if(distSq < radius^2)
		collide = 1;
	else
		collide = 0;
	endif
	
endfunction

function collided = circleCircleCollision(x1,y1,x2,y2,radius)
	dx = (x2-x1);
	dy = (y2-y1);
	if((dx^2 + dy^2) <= (2*radius)^2)
		collided = 1;
	else 
		collided = 0;
	endif
endfunction

function regOfCorners = getRegionOfCorners(x1, y1 , x2, y2)
	global map;
	
	size = map.blockSize;
	x1 = int32(x1);
	y1 = int32(y1);
	x2 = int32(x2);
	y2 = int32(y2);
	cX1 = ((x1-mod(x1,size))/size) + 1;
	cY1 = ((y1-(mod(y1,size)))/size) + 1;
	cX2 = ((x2-(mod(x2,size)))/size) + 1;
	cY2 = ((y2-(mod(y2,size)))/size) + 1;
	
	if(cX1 == cX2 && cY1 == cY2)
		regOfCorners = [cX1,cY1;cX1,cY1;cX1,cY1;cX1,cY1];
		return;
	endif

	cX3 = ((x1-(mod(x1,map.blockSize)))/50) + 1;
	cY3 = ((y2-(mod(y2,map.blockSize)))/50) + 1;
	cX4 = ((x2-(mod(x2,map.blockSize)))/50) + 1;
	cY4 = ((y1-(mod(y1,map.blockSize)))/50) + 1;
	
	regOfCorners = [cX1,cY1;cX2,cY2;cX3,cY3;cX4,cY4];
endfunction