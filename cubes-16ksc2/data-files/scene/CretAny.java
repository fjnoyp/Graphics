import java.util.ArrayList; 
//import java.io.PrintWriter;  
import java.io.*; 

import java.lang.Math; 

class CretAny{

    private PrintWriter writer; 
    public static boolean STRINGIFY = true; 

    public CretAny(){
        String name = "custom"; 

        File file = new File(name+".scn.any"); 
        try{
            writer = new PrintWriter(file,"UTF-8"); 
        } catch(Exception e){
            System.out.println("not working"); 
        }

        //Initialization 
        writeToFile("// -*- c++ -*-"); 
        writeToFile("{"); 

        writeToFile("name = \""+name+"\";"); 
        
        //Models 
        writeToFile("models = {"); 

        int stepSize = 120; 
        int halfStepSize = (int)(stepSize/2); 

        float minColorIntensity = .1f; 

        float maxColorIntensity =  (halfStepSize/(float)(halfStepSize*1.5F))+minColorIntensity; 

        int curColor = 0; 
        
        float xCurve = 40; 

        for(int i = 0; i<stepSize; i++){
            G3DObject woodenModel = new G3DObject("woodenModel"+i,"ArticulatedModel::Specification"); 
            woodenModel.setCommand("filename","model/cube/cube.obj",STRINGIFY); 

            G3DObject woodPreProc = new G3DObject("preprocess",""); 

            //
            if( i<halfStepSize ){
                curColor ++; 
            }
            else{
                curColor --; 
            }
            float colorIntensity = (curColor / (float)(halfStepSize*1.5f)) + minColorIntensity; 
            //float colorIntensity = .5f; 

            //woodPreProc.setColor( 2*colorIntensity, maxColorIntensity-colorIntensity, colorIntensity); 
            woodPreProc.setColor( colorIntensity, colorIntensity, colorIntensity); 
            float scale = (float)(Math.abs(20*Math.cos(i*Math.PI/stepSize))); 
            woodPreProc.setScale( 2*scale, 1, 2*scale ); 
            woodenModel.addG3DObject(woodPreProc); 

            writeObject(woodenModel); 
        }
        
        writeToFile("};"); 

        //Entities 
        writeToFile("entities = {"); 


        for(int i = 0; i<stepSize*4; i++){
            xCurve = (float)(40*  Math.cos(i*(Math.PI/(stepSize*2)))); 
            G3DObject cube = new G3DObject("cube"+i,"VisibleEntity"); 
            cube.setCommand("model","woodenModel"+(i%stepSize),STRINGIFY); 
            cube.setTrack((float)(xCurve*Math.cos(i*(Math.PI/stepSize))),
                          i,
                          (float)(xCurve*Math.sin(i*(Math.PI/stepSize))),
                          0,
                          (float)(360*Math.sin(i*(Math.PI/(stepSize)))),
                          0,
                          2,
                          20f,
                          313); 
                          //300+(float)(60*Math.sin(i*(Math.PI/(stepSize))))); 
            writeObject(cube); 
        }

        G3DObject camera = new G3DObject("camera","Camera"); 
        camera.setFrame(0,0,5); 
        writeObject(camera); 
        
        writeToFile("};"); 

        //End
        writeToFile("};"); 

        writer.close(); 
    }

    public void writeToFile(String contents){
        writer.println(contents); 
    }
    
    public void writeObject(Writable object){
        ArrayList<String> strings = object.getCommands(); 
        for(int i = 0; i<strings.size(); i++){
            writeToFile(strings.get(i)); 
        }
    }

    public static void main(String[] args){
        System.out.println("running"); 
        new CretAny(); 
    }

}

interface Writable{
    public ArrayList<String> getCommands(); 
}
class G3DObject implements Writable{

    String name; 
    ArrayList<String> commands; 

    

    public G3DObject(String name, String type){
        this.name = name;
        commands = new ArrayList<String>(); 
        commands.add(name + " = " + type + "{"); 
    }

    //Generic method
    public void setCommand(String type, String value, boolean stringValue){
        if(!stringValue)
            commands.add(type + " = " + value+";"); 
        else
            commands.add(type + " = \""+value+"\";"); 
    }

    //Methods for ArticulatedModel 
    /*
    public void setMaterial(String filePath){
        commands.add("preprocess = {"); 
        commands.add("setMaterial(all(),\""+filePath+"\");");
        commands.add("};"); 
    }
    */

    //methods for VisibleEntity
    public void setFrame(float x, float y, float z){
        commands.add("frame = " +crPosition(x,y,z) +";"); 
    }
    public void setFrame(float x, float y, float z, float rotx, float roty, float rotz){
        commands.add("frame = " + crPosition(x,y,z,rotx,roty,rotz)+";");
    }

    public void addG3DObject(G3DObject otherObject){
        commands.addAll(otherObject.getCommands()); 
    }
    //methods for preprocess 
    public void setColor(float redInt, float greenInt, float blueInt){
        commands.add("setMaterial(all(),Color3("+redInt+","+greenInt+","+blueInt+"));"); 
    }
    public void setMaterial(String filePath){
        commands.add("setMaterial(all(),\""+filePath+"\");");
    }
    public void setScale(float xScale, float yScale, float zScale){
        commands.add("transformGeometry(all(),Matrix4::scale("+xScale+","+yScale+","+zScale+"));"); 
    }

    public void setTrack(float x, float y, float z, float rotx, float roty, float rotz, float orbitRadius, float orbitTime){
        commands.add("track = transform(" + crPosition(x,y,z,rotx,roty,rotz) + "," + crOrbit(orbitRadius,orbitTime) + ");"); 
    }

    public void setTrack(float x, float y, float z, float rotx, float roty, float rotz, float orbitRadius, float orbitTime, float rollDegree){
        commands.add("track = transform(" + crPosition(x,y,z,rotx,roty,rotz) + ","+
                     "transform("+crOrbit(orbitRadius,orbitTime)+",Matrix4::rollDegrees("+rollDegree+")) );"); 
    }


    private String crOrbit(float orbitRadius, float orbitTime){
        return "orbit("+orbitRadius+","+orbitTime+")"; 
    }
    private String crPosition(float x, float y, float z, float rotx, float roty, float rotz){
        return "CFrame::fromXYZYPRDegrees("+x+","+y+","+z+","+roty+","+rotx+","+rotz+")"; 
    }
    private String crPosition(float x, float y, float z){ 
        return "CFrame::fromXYZYPRDegrees("+x+","+y+","+z+")"; 
    }


    public ArrayList<String> getCommands(){
        commands.add("};"); 
        return commands; 
    }

}
