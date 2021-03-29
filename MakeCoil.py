#Author- ARR 2021.03.28
#Description- Converts FaceData Contours to an assembly. Facedata contours are stored as CSV.

import adsk.core, adsk.fusion, adsk.cam, traceback
import math

wiredatafile = 'C:\\Users\\ausreid\\Documents\\Fusion 360\\wires\\SpiralDebug.csv'
# wiredatafile = ''

def run(context):
    ui = None
    try:
        app = adsk.core.Application.get()
        ui  = app.userInterface
        
        des = adsk.fusion.Design.cast(app.activeProduct)
        root = des.rootComponent
        
        # # Create a new sketch.
        # sk = root.sketches.add(root.xYConstructionPlane)
        
        # # Draw two circles on the sketch to use to create a tube.
        # insideRad = 15
        # outsideRad = 20
        # circs = sk.sketchCurves.sketchCircles
        # circs.addByCenterRadius(adsk.core.Point3D.create(0,0,0), insideRad)
        # circs.addByCenterRadius(adsk.core.Point3D.create(0,0,0), outsideRad)
 
        # # Find the "outer" profile.
        # prof = adsk.fusion.Profile.cast(None)
        # for prof in sk.profiles:
        #     if prof.profileLoops.count == 2:
        #         break
 
        # # Create an extrusion.
        # ext = root.features.extrudeFeatures.addSimple(prof, adsk.core.ValueInput.createByReal(1520), 
        #                                               adsk.fusion.FeatureOperations.NewBodyFeatureOperation)
        # cylinderBody = ext.bodies.item(0)
 
        # Create a series of temporary solid bodies that represent the cylinders.                                                      
        tempBRep = adsk.fusion.TemporaryBRepManager.get()
 
        cylinders = []  
        radius = 0.005
        # angle = 0
        # offset = 2.5
        targetBody = adsk.fusion.BRepBody.cast(None)
        ui.messageBox('Here we go!')
        wirecount = 0
        wire_indices = 'true'
        with open(wiredatafile) as f:
            wire_indices = f.readline()
            wireset = f.readline()
            while wire_indices:
                wirecount += 1
                
                wire_points = wireset.split(',')

                for coord1,coord2 in zip(wire_points[:-1],wire_points[1:]):
                    coord1 = coord1.replace('(','')
                    coord1 = coord1.replace(')','')
                    xyz = coord1.split(' ')
                    x = float(xyz[0])
                    y = float(xyz[1])
                    z = float(xyz[2])
                    # Compute the coordinates of the first point of the cylinder.
                    pnt1 = adsk.core.Point3D.create(x,y,z)
                                
                    coord2 = coord2.replace('(','')
                    coord2 = coord2.replace(')','')
                    xyz = coord2.split(' ')      
                    x = float(xyz[0])
                    y = float(xyz[1])
                    z = float(xyz[2])     
                    # Compute the coordinates of the second point of the cylinder.
                    pnt2 = adsk.core.Point3D.create(x,y,z)
                    
                    # Create the temporary cylinder.
                    cylinder = tempBRep.createCylinderOrCone(pnt1, radius, pnt2, radius)
                    if not targetBody:
                        targetBody = cylinder
                    else:
                        # Union the cylinder with the previous cylinder.
                        tempBRep.booleanOperation(targetBody, cylinder, adsk.fusion.BooleanTypes.UnionBooleanType)
                wire_indices = f.readline()
                if wire_indices:
                    wireset = f.readline()
        
        ui.messageBox('We made some wires, maybe! This many? '+str(wirecount))
        # Create a new base feature.
        baseFeat = root.features.baseFeatures.add()
        baseFeat.startEdit()
        
        cylindersBody = root.bRepBodies.add(targetBody, baseFeat)
        
        baseFeat.finishEdit()
        
        toolBodies = adsk.core.ObjectCollection.create()
        toolBodies.add(baseFeat.bodies.item(0))
        # combineInput = root.features.combineFeatures.createInput(cylinderBody, toolBodies)
        # combineInput.operation = adsk.fusion.FeatureOperations.CutFeatureOperation
        # root.features.combineFeatures.add(combineInput)
        
        app.activeViewport.fit()
    except:
        if ui:
            ui.messageBox('Failed:\n{}'.format(traceback.format_exc()))
