function stackcylinders(model, facedata, wire_r, newsel)
% function stackcylinders(facedata)
%
% Take facedata structure and insert it as a series of cylinders in the
% current model.

model.param.set('wire_r', wire_r);

geo = model.component('comp1').geom('geom1');

cylN = 0;

faces = length(facedata);

for i = 1:faces
    model.param.set(['drawface' num2str(i)], '1');
    geo.create(['if' num2str(i)], 'If');
    geo.feature(['if' num2str(i)]).set('condition', ['drawface' num2str(i) '==1']);
    csel = ['csel' num2str(i)];
    if newsel
        geo.selection.create(csel, 'CumulativeSelection');
        geo.selection(csel).label(['tubeface' num2str(i)]);
    end
    
    M = facedata{i}{4};
    levels = length(facedata{i}{5});
    for j = 1:levels
        isowires = length(facedata{i}{5}{j});
        for k = 1:isowires
            contourdata = affineRestore(facedata{i}{5}{j}{k}(1,:),facedata{i}{5}{j}{k}(2,:),M);
            cylN = insertCylinders(model,contourdata, cylN, csel);
        end
    end
    geo.create(['endif' num2str(i)], 'EndIf');
end
for i=1:faces
    bundle_i = faces+i;
    geo.create(['if' num2str(bundle_i)], 'If');
    geo.feature(['if' num2str(bundle_i)]).set('condition', ['drawface' num2str(i) '==1']);
    geo.create(['uni' num2str(i)], 'Union');
    union = model.component('comp1').geom('geom1').feature(['uni' num2str(i)]);
    union.set('contributeto', ['csel' num2str(i)]);
	union.set('intbnd', false);
	union.selection('input').named(['csel' num2str(i)]);
	geo.create(['endif' num2str(bundle_i)], 'EndIf');
end
geo.run;
% geo.run('fin');
end
function cylN = insertCylinders(model,contourdata, cylN, grouping)
    geo = model.component('comp1').geom('geom1');
    [~,n] = size(contourdata);
    diffdata = diff(contourdata,[],2);
    cylinderh = sqrt(sum(diffdata.*diffdata));
    for pti = 1:(n-1)
        cylN = cylN + 1;
        cylstring = ['cyl' num2str(cylN)];
        ballstring = ['sph' num2str(cylN)];
        geo.create(cylstring, 'Cylinder');
        cyl = geo.feature(cylstring);
        cyl.set('contributeto', grouping);
        cyl.set('pos', contourdata(:,pti)');
        cyl.set('axis', diffdata(:,pti)');
        cyl.set('r', 'wire_r');
        cyl.set('h', cylinderh(pti));
        geo.create(ballstring, 'Sphere');
        ball = geo.feature(ballstring);
        ball.set('r', 'wire_r');
        ball.set('pos', contourdata(:,pti)');
        ball.set('contributeto', grouping);
    end
end