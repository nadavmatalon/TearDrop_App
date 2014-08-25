
// TearDrop
// Pump & Fan Controllers App
// Version 99.0 
// PROCESSING 2.0
// Created by Nadav Matalon
// 24 August 2014

// (TDCR_app_complete_99)


import processing.serial.*;

import java.awt.*;
import java.awt.event.*;
import java.awt.Frame;
import java.io.*;

import com.sun.jna.Native;
import com.sun.jna.NativeLong;
import com.sun.jna.WString;

import javax.swing.*;
import javax.swing.JMenuItem;
import javax.swing.JPopupMenu;
import javax.swing.border.BevelBorder;


Serial portOne;            // SERIAL PORT: COM5 (PUMP)
Serial portTwo;            // SERIAL PORT: COM6 (FAN)

Console debug_console;

JFrame debug_frame = new JFrame("TEARDROP DEBUG CONSOLE");

secondApplet sensor_applet;

PFrame sensor_frame;

SystemTray tray = SystemTray.getSystemTray();

PFont font1;
PFont font2;
PFont font3;
PFont font4;

PImage background_image;
PImage background_image_2;
PImage button_image;
PImage button_hover;
PImage taskbar_image;
PImage system_tray_image;

JMenuItem lock_position = new JMenuItem("Lock Window Position");
JMenuItem unlock_position = new JMenuItem("Unlock Window Position");
JMenuItem warning_on = new JMenuItem("System Warning On");
JMenuItem warning_off = new JMenuItem("System Warning Off");
JMenuItem sensor_on = new JMenuItem("Open Sensor Window");
JMenuItem sensor_off = new JMenuItem("Close Sensor Window");
JMenuItem debug_on = new JMenuItem("Open Debug Window");
JMenuItem debug_off = new JMenuItem("Close Debug Window");
JMenuItem single_device = new JMenuItem("Single Data Input");
JMenuItem dual_device = new JMenuItem("Dual Data Input");
JMenuItem close = new JMenuItem ("Close");

JMenuItem sensor_lock_position = new JMenuItem("Lock Window Position");
JMenuItem sensor_unlock_position = new JMenuItem("Unlock Window Position");
JMenuItem sensor_close = new JMenuItem ("Close");


final boolean CONSTRAIN_FRAME = false;    // CONSTRAIN_FRAME
//final boolean CONSTRAIN_FRAME = true;

final int WINDOW_WIDTH = 210;                // MAIN_WINDOW_SIZE_X
final int WINDOW_HEIGHT = 816;               // MAIN_WINDOW_SIZE_Y

final int WINDOW_POSITION_X = 650;          // WINDOW_POSITION_X
final int WINDOW_POSITION_Y = 50;           // WINDOW_POSITION_Y

final int SENSOR_WINDOW_POSITION_X = 400;    // SENSOR_WINDOW_POSITION_X
final int SENSOR_WINDOW_POSITION_Y = 450;    // SENSOR_WINDOW_POSITION_Y

final int SENSOR_WINDOW_WIDTH = 210;         // SENSOR_WINDOW_SIZE_X
final int SENSOR_WINDOW_HEIGHT = 171;        // SENSOR_WINDOW_SIZE_X

// final int BAUD_RATE = 115200;             // BAUD_RATE
// final int BAUD_RATE = 230400;             // BAUD_RATE
final int BAUD_RATE = 250000;                // BAUD_RATE
// final int BAUD_RATE = 345600;             // BAUD_RATE
// final int BAUD_RATE = 500000;             // BAUD_RATE

final byte NUM_WARNING_FLAGS = 39;           // SYSTEM_WARNING_FLAGS

final TrayIcon trayIcon = null;

final int PC_SYSTEM_STATUS = 1001;           // SYSTEM_STATUS (OK/WARNING/ALARM/NO_DATA)  // PC_SYSTEM_STATUS processing update command
final int PC_PUMP_CONTROL_1 = 1002;          // PUMP_CONTROL_1(OVD_OFF/OVD_ON)            // PC_PUMP_CONTROL_1 processing update command
final int PC_PUMP_CONTROL_2 = 1003;          // PUMP_CONTROL_2(MAN/AUTO)                  // PC_PUMP_CONTROL_2 processing update command
final int PC_VCC_PUMP = 1004;                // PUMP_VCC                                  // PC_PUMP_VCC processing update command
final int PC_VCC_ICP = 1005;                 // VCC_ICP                                   // PC_VCC_ICP processing update command
final int PC_PUMP_MODE = 1006;               // PUMP_MODE (VCC/PWM)                       // PC_PUMP_MODE_1 processing update command
final int PC_PUMP_RPM_1 = 1007;              // PUMP_RPM_1                                // PC_PUMP_RPM_1 processing update command
final int PC_PUMP_RPM_2 = 1008;              // PUMP_RPM_2                                // PC_PUMP_RPM_2 processing update command
final int PC_PSU_RPM = 1009;                 // PSU_RPM                                   // PC_PSU_RPM processing update command
final int PC_PUMP_FLOW = 1010;               // PUMP_FLOW                                 // PC_PUMP_FLOW processing update command
final int PC_DUTY_CYCLE_PER = 1011;          // PUMP_DUTY_CYCLE_PER                       // PC_DUTY_CYCLE_PER processing update command
final int PC_TEMP_AN1 = 1012;                // TEMP_AN1                                  // PC_TEMP_AN1 processing update command
final int PC_TEMP_AN2 = 1013;                // TEMP_AN2                                  // PC_TEMP_AN2 processing update command
final int PC_TEMP_DGP = 1014;                // TEMP_DGP (PC_TEMP_OW_1)                   // PC_TEMP_DGP processing update command
final int PC_TEMP_ICP = 1015;                // TEMP_ICP                                  // PC_TEMP_ICP processing update command
final int PC_FREQ_VCC = 1016;                // FREQ_VCC                                  // PC_FREQ_VCC processing update command
final int PC_FREQ_PWM = 1017;                // FREQ_PWM                                  // PC_FREQ_PWM processing update command
final int PC_RAM_ICP = 1018;                 // RAM_ICP                                   // PC_ICP_RAM processing update command

final int PC_TEMP_OW_1 = 1019;               // TEMP_OW_1 (PC_TEMP_OW_2)                  // PC_TEMP_OW_1 processing update command
final int PC_TEMP_OW_2 = 1020;               // TEMP_OW_2 (PC_TEMP_OW_3)                  // PC_TEMP_OW_2 processing update command

final int PC_TEMP_I2C_1 = 1021;              // TEMP_I2C_1 (PC_TEMP_I2C_1)                // PC_TEMP_I2C_1 processing update command
final int PC_TEMP_I2C_2 = 1022;              // TEMP_I2C_2 (PC_TEMP_I2C_2)                // PC_TEMP_I2C_2 processing update command


final int FC_FAN_CONTROL_1 = 2001;           // FAN_CONTROL_1 (OVD_OFF/OVD_ON)            // FC_FAN_CONTROL_1 processing update command
final int FC_FAN_CONTROL_2 = 2002;           // FAN_CONTROL_2 (MAN/AUTO)                  // FC_FAN_CONTROL_2 processing update command
final int FC_VCC_FAN_1 = 2003;               // FAN_VCC_1                                 // FC_FAN_VCC_1 processing update command
final int FC_VCC_FAN_2 = 2004;               // FAN_VCC_2                                 // FC_FAN_VCC_2 processing update command
final int FC_VCC_ICF = 2005;                 // VCC_ICF (BOTTOM)                          // FC_VCC_ICF processing update command
final int FC_FAN_MODE_1 = 2006;              // FAN_MODE_1 (VCC_1/PWM_1)                  // FC_FAN_MODE_1 processing update command
final int FC_FAN_RPM_1 = 2007;               // FAN_RPM_1                                 // FC_FAN_RPM_1 processing update command
final int FC_FAN_RPM_2 = 2008;               // FAN_RPM_2                                 // FC_FAN_RPM_2 processing update command
final int FC_FAN_RPM_3 = 2009;               // FAN_RPM_3                                 // FC_FAN_RPM_3 processing update command
final int FC_FAN_RPM_4 = 2010;               // FAN_RPM_4                                 // FC_FAN_RPM_4 processing update command
final int FC_DUTY_CYCLE_PER_1 = 2011;        // FAN_DUTY_CYCLE_PER_1                      // FC_DUTY_CYCLE_PER_1 processing update command
final int FC_FAN_MODE_2 = 2012;              // FAN_MODE_2 (VCC_2/PWM_2)                  // FC_FAN_MODE_2 processing update command
final int FC_FAN_RPM_5 = 2013;               // FAN_RPM_5                                 // FC_FAN_RPM_5 processing update command
final int FC_FAN_RPM_6 = 2014;               // FAN_RPM_6                                 // FC_FAN_RPM_6 processing update command
final int FC_DUTY_CYCLE_PER_2 = 2015;        // FAN_DUTY_CYCLE_PER_2                      // FC_DUTY_CYCLE_PER_2 processing update command
final int FC_TEMP_AN3 = 2016;                // TEMP_AN3                                  // FC_TEMP_AN1 processing update command
final int FC_TEMP_AN4 = 2017;                // TEMP_AN4                                  // FC_TEMP_AN2 processing update command
final int FC_TEMP_DGF = 2018;                // TEMP_DGF (FC_TEMP_OW_1)                   // FC_TEMP_DGF processing update command
final int FC_TEMP_ICF = 2019;                // TEMP_ICF (TOP)                            // FC_TEMP_ICF processing update command
final int FC_FREQ_VCC_1 = 2020;              // FREQ_VCC_1                                // FC_FREQ_VCC_1 processing update command
final int FC_FREQ_PWM_1 = 2021;              // FREQ_PWM_1                                // FC_FREQ_PWM_1 processing update command
final int FC_FREQ_VCC_2 = 2022;              // FREQ_VCC_2                                // FC_FREQ_VCC_2 processing update command
final int FC_FREQ_PWM_2 = 2023;              // FREQ_PWM_2                                // FC_FREQ_PWM_2 processing update command
final int FC_RAM_ICF = 2024;                 // RAM_ICF (BOTTOM)                          // FC_ICF_RAM processing update command

final int FC_TEMP_OW_3 = 2025;               // TEMP_OW_3 (FC_TEMP_OW_2)                  // FC_TEMP_OW_3 processing update command
final int FC_TEMP_OW_4 = 2026;               // TEMP_OW_4 (FC_TEMP_OW_3)                  // FC_TEMP_OW_4 processing update command

final int FC_TEMP_I2C_3 = 2027;              // TEMP_I2C_3 (FC_TEMP_I2C_1)                // FC_TEMP_I2C_3 processing update command
final int FC_TEMP_I2C_4 = 2028;              // TEMP_I2C_4 (FC_TEMP_I2C_2)                // FC_TEMP_I2C_4 processing update command


boolean[] warning_flag = new boolean[NUM_WARNING_FLAGS];

boolean COM5_present = false;
boolean COM6_present = false;
boolean COM9_present = false;

int num_serial_ports = 0;

String pump_com_port = "-";

String fan_com_port = "-";

boolean TDPC_connected = false;        // PUMP_CONTROLLER_CONNECTION_FLAG
boolean TDFC_connected = false;        // FAN_CONTROLLER_CONNECTION_FLAG

int pump_baud_rate = 0;

int fan_baud_rate = 0;

boolean button_hover_remove = false;

JPopupMenu popup = new JPopupMenu();

JPopupMenu sensor_popup = new JPopupMenu();

boolean system_warning_control = false;      // SYSTEM_WARNING_CINTROL (OFF/ON)

boolean window_lock = false;                 // MAIN_WINDOW_LOCK (OFF/ON)

boolean single_input = true;                 // DATA_INPUT_MODE (DUAL/SINGLE)

boolean open_debug_window = false;           // DEBUG_WINDOW (CLOSE/OPEN)

boolean debug_mode_on = false;               // DEBUG_MODE (OFF/ON)

boolean sensor_window_lock = false;           // SENSOR_WINDOW_LOCK (OFF/ON)

boolean open_sensor_window = false;          // SENSOR_WINDOW (CLOSE/OPEN)

boolean sensor_mode_on = false;              // SENSOR_MODE (OFF/ON)

boolean sensor_quit_active = false;

boolean sensor_button_hover_remove = false;

boolean scroll_on = true;

boolean debug_quit = false;

int pos_x = 0;
int pos_y = 0;
int sensor_pos_x = 0;
int sensor_pos_y = 0;
int pMouseX = 0;
int pMouseY = 0;
int global_mouse_x = 0;
int global_mouse_y = 0;
int p_global_mouse_x = 0;
int p_global_mouse_y = 0;

boolean frame_in_place = false;

int current_system_status = 0;
int previous_system_status = 5;

boolean pump_overdrive = true;
boolean fan_overdrive = true;

boolean system_warning = false;
boolean system_alarm = false;

int counter = 0;

boolean no_data_yet = true;
boolean no_general_data = false;
boolean no_pump_data = false;
boolean no_fan_data = false;
int pump_data_monitor = 0;
int fan_data_monitor = 0;

String checkString = "";
String device_name = "";
int device_type = 0;                       
int device_CRC = 0;
String device_data = "";
String data = "";

boolean crc_validation = false;

int index = 0;
int index2 = 0;

float pump_duty_bar = 54;
float fan_duty_bar_1 = 54;
float fan_duty_bar_2 = 54;

final long UPDATE_INTERVAL = 1000;                    
long update_tick = 0;                      
long update_tock = 0;      


void init() {
 
  frame.removeNotify();
  frame.setType(Window.Type.UTILITY);
  frame.setUndecorated(true);
//  frame.setAlwaysOnTop(true);
  frame.addNotify(); 
  super.init();
}


void setup() {

  background_image = loadImage("background_image.png");
  background_image_2 = loadImage("background_image_2.png");
  button_image = loadImage("button_image.png");  
  button_hover = loadImage("button_hover.png");
  taskbar_image = loadImage("taskbar_image.png");
  system_tray_image = loadImage("system_tray_image.png");

  font1 = loadFont("SourceCodePro-Bold-14.vlw");
  font2 = loadFont("SourceCodePro-Regular-12.vlw");
  font3 = loadFont("SourceCodePro-Bold-12.vlw");
  font4 = loadFont("Dialog.plain-11.vlw");

  frameRate(200);
  smooth();  
  colorMode(RGB);
  size(WINDOW_WIDTH, WINDOW_HEIGHT);
  background(background_image);
  image(button_image, 178, 13);

  frame.setIconImage(taskbar_image.getImage());
  frame.setTitle("TEARDROP");
  frame.setExtendedState(frame.NORMAL); 

  frame.addWindowStateListener(new WindowStateListener() {
    public void windowStateChanged(WindowEvent e) {
      if ((frame.getExtendedState()) != frame.NORMAL) frame.setExtendedState(frame.NORMAL);
      if (e.getNewState() != frame.NORMAL) frame.setExtendedState(frame.NORMAL);
    }
  });

  createSystemTrayIcon();

  add_Window_Listeners();

  add_popupMenu();

  select_Com_Port();
    
  create_Header();
  create_Device_List();
  create_Inivital_Values();
  create_Units();
  create_Duty_Bar();
}


void draw() {

    if ((frameCount < 20) && (!frame_in_place)) set_Frame_Position ();      // SET_FRAME_POSITION

  if ((device_CRC > 0) && (compare_CRC())) {            // GOT_DATA
  
    read_Data();

  } else {                                      

    pump_data_monitor += 1;
    fan_data_monitor += 1;
  }
  
  if (pump_data_monitor >= 1750) pump_No_Data();                      // NO_PUMP_DATA

  if (fan_data_monitor >= 1750) fan_No_Data();                        // NO_FAN_DATA

  if ((no_pump_data) && (no_fan_data)) no_general_data = true;        // NO_DATA
  else no_general_data = false;

  update_System_Status();

  update_tock = millis();

  if ((update_tock - update_tick) >= UPDATE_INTERVAL) {    
  
    update_tick = update_tock;          

    update_COM_Port();

    check_Image_Cache();
  }

  if (open_debug_window) {                // DEBUG_WINDOW
    open_debug_window = false;
    try {
      debug_console = new Console();
      
    } catch(Exception e) {
    }

  }


  if (open_sensor_window) {                // SENSOR_WINDOW
    open_sensor_window = false;
    try {
      PFrame sensor_frame = new PFrame();

    } catch(Exception e) {
    }
  }


  if (sensor_quit_active) {

    sensor_quit_active = false;
    sensor_on.setEnabled(true);
    sensor_off.setEnabled(false);
    sensor_mode_on = false;
  }
}




void print_Debug (String debug_string) {              // DEBUG_PRINT (STRING)

  if (debug_mode_on) {
    println(debug_string);
    println("");
  }
}


void print_Debug (int debug_int) {                // DEBUG_PRINT (INT)

  if (debug_mode_on) {
    println(debug_int);
    println("");
  }
}


void set_Frame_Position () {                  // SET_FRAME_POSITION
  
  if (((int(frame.getLocation().x)) != WINDOW_POSITION_X) || ((int(frame.getLocation().y))) != WINDOW_POSITION_Y) 
     frame.setLocation(WINDOW_POSITION_X, WINDOW_POSITION_Y);

  if (((int(frame.getLocation().x)) == WINDOW_POSITION_X) && ((int(frame.getLocation().y))) == WINDOW_POSITION_Y) {
    print_Debug("set main window in place");
    frame_in_place = true;  
  } else {
    print_Debug("could not set main window in place");
    frame_in_place = false;
  }
}


void check_Image_Cache() {                  // CHECK_IMAGE_CACHE
        
  clear_Image_Cache(background_image, "background_image");
  clear_Image_Cache(background_image_2, "background_image_2");
  clear_Image_Cache(taskbar_image, "taskbar_image");
  clear_Image_Cache(button_image, "button_image");
  clear_Image_Cache(button_hover, "button_hover");
  clear_Image_Cache(system_tray_image, "system_tray");
}


void clear_Image_Cache (PImage cache_image, String image_name) {        // CLEAR_IMAGE_CACHE

  if (g.getCache(cache_image) != null) {

    print_Debug(image_name + " image cache: " + g.getCache(cache_image));
    g.removeCache(cache_image);
    print_Debug(image_name + " image cache: " + g.getCache(cache_image));
  }
}


public void createSystemTrayIcon() {                // SYSTEM_TRAY_ICON

  PopupMenu popup = new PopupMenu();

  final MenuItem menuExit = new MenuItem("Close");

  ActionListener exitListener = new ActionListener() {

    public void actionPerformed(ActionEvent e) {

      exit();
    }
  };

  menuExit.addActionListener(exitListener);

  popup.add(menuExit);

  final TrayIcon trayIcon = new TrayIcon(system_tray_image.getImage(), "TEARDROP", popup);

  ActionListener actionListener = new ActionListener() {

    public void actionPerformed(ActionEvent e) {

      trayIcon.displayMessage("TEARDROP", "", TrayIcon.MessageType.INFO); 
    }

  };

  trayIcon.addActionListener(actionListener);

  try {

    tray.add(trayIcon);

  } catch (AWTException e) {

    print_Debug("could not add system tray icon");
  }
}


void update_COM_Port() {                // UPDATE_COM_PORT

  if (single_input) {                // SINGLE_DATA_INPUT

    if ((!TDPC_connected) && (!TDFC_connected)) select_Com_Port();
      
  } else {                  // DUAL_DATA_INPUT

    if ((!TDPC_connected) || (!TDFC_connected)) select_Com_Port();
  }
}


void select_Com_Port() {                // SELECT_COM_PORT
 
  boolean TDPC_initialized = false;
  boolean TDFC_initialized = false;

  if (Serial.list() != null) {
    
    num_serial_ports = (Serial.list()).length; 
    print_Debug("serial port/s found: " + num_serial_ports + " port/s");  

    if (num_serial_ports > 0) {
      for (int i=0; i < num_serial_ports; i++) {
        print_Debug("serial port " + i + ": " + (Serial.list()[i]));
        if (Serial.list()[i].equals("COM5")) COM5_present = true;
        if (Serial.list()[i].equals("COM6")) COM6_present = true;
        if (Serial.list()[i].equals("COM9")) COM9_present = true;
      }

      if ((COM5_present) && (!TDPC_connected)) {

        pump_com_port = "COM5";
        pump_baud_rate = BAUD_RATE;

        try {

          portOne = new Serial(this, pump_com_port, pump_baud_rate);

          TDPC_initialized = true;

        } catch (RuntimeException e) {

          if (e.getMessage().contains("<init>")) {

            print_Debug("cannot connect pump_com_port: COM5 already in use");


           } else {

            print_Debug("cannot connect pump_com_port: COM5 could not connect");
           }

          TDPC_initialized = false;
            }

        if (TDPC_initialized) {

          portOne.bufferUntil('!');
        
          TDPC_connected = true;

          draw_Pump_Port();

        } else {

          TDPC_connected = false;
        }
        
      } else if ((COM9_present) && (!TDPC_connected)) {

        pump_com_port = "COM9";
        pump_baud_rate = BAUD_RATE;

        try {

          portOne = new Serial(this, pump_com_port, pump_baud_rate);

          TDPC_initialized = true;

        } catch (RuntimeException e) {


          if (e.getMessage().contains("<init>")) {

            print_Debug("cannot connect pump_com_port: COM9 already in use");


           } else {

            print_Debug("cannot connect pump_com_port: COM9 could not connect");
           }

          TDPC_initialized = false;
            }

        if (TDPC_initialized) {

          portOne.bufferUntil('!');
        
          TDPC_connected = true;

          draw_Pump_Port();

        } else {

          TDPC_connected = false;
        }

      }


      if ((COM6_present) && (!TDFC_connected)) {

        fan_com_port = "COM6";
        fan_baud_rate = BAUD_RATE;

        try {

          portTwo = new Serial(this, fan_com_port, fan_baud_rate);

          TDFC_initialized = true;

        } catch (RuntimeException e) {


          if (e.getMessage().contains("<init>")) {

            print_Debug("cannot connect fan_com_port: COM6 already in use");


           } else {

            print_Debug("cannot connect fan_com_port: COM6 could not connect");
           }

          TDFC_initialized = false;
            }

        if (TDFC_initialized) {

          portTwo.bufferUntil('!');
        
          TDFC_connected = true;

          draw_Fan_Port();

        } else {

          TDFC_connected = false;
        }

      }

      print_Debug("serial port/s selected: ");

      if (TDPC_connected) {
        print_Debug("pump_com_port: " + pump_com_port);
        print_Debug("pump_baud_rate: " +pump_baud_rate);

      } else {
        print_Debug("pump_com_port: not connected");
      }

      if (TDFC_connected) {
        print_Debug("fan_com_port: " + fan_com_port);
        print_Debug("fan_baud_rate: " + fan_baud_rate);
      } else {
        print_Debug("fan_com_port: not connected");
      }
    }

  } else {    

    print_Debug("no serial ports found");
  }
}


void serialEvent (Serial thisPort) {              // SERIAL_DATA_IN

  if ((counter == 0) && (thisPort.available() >= 1)) {
    String dataStart = new String (thisPort.readBytesUntil('!'));
    counter = 1;
  }   
  while (thisPort.available() >= 1) {
    data = new String(thisPort.readBytesUntil('!'));
    if (data != null) {

      if (debug_mode_on) {
  
        print_Debug("--------------------------");

        print_Debug("raw data: " + data);

      }

      checkString = data.substring(data.length()-1);

      if ((checkString != null) && (checkString.equals("!") == true)) {  

        data = data.substring(0, data.length()-1);        

        index = data.indexOf(",", 0);                

        index2 = data.indexOf(",", index+1); 

        if ((data != null) && (index == 4) && (index2 == 10)) {
          device_type = int(data.substring(0, index));
          device_CRC = int(data.substring(index+1, index2));
          device_data = data.substring(index2+1, data.length());

          if (debug_mode_on) {

            print_Debug("checkString: " + checkString);

            print_Debug("index: " + index);

            print_Debug("index2: " + index2);

            print_Debug("trimmed data: " + data);  

            switch(device_type) {

              case (PC_SYSTEM_STATUS): device_name = "PC_SYSTEM_STATUS (OK/WARNING/ALARM/NO_DATA)"; break;
              case (PC_PUMP_CONTROL_1): device_name = "PC_PUMP_CONTROL_1(OVD_OFF/OVD_ON)"; break;
              case (PC_PUMP_CONTROL_2): device_name = "PC_PUMP_CONTROL_2(MAN/AUTO)"; break;
              case (PC_VCC_PUMP): device_name = "PC_VCC_PUMP"; break;
              case (PC_VCC_ICP): device_name = "PC_VCC_ICP"; break;
              case (PC_PUMP_MODE): device_name = "PC_PUMP_MODE (VCC/PWM)"; break;
              case (PC_PUMP_RPM_1): device_name = "PC_PUMP_RPM_1"; break;
              case (PC_PUMP_RPM_2): device_name = "PC_PUMP_RPM_2"; break;
              case (PC_PSU_RPM): device_name = "PC_PSU_RPM"; break;
              case (PC_PUMP_FLOW): device_name = "PC_PUMP_FLOW"; break;
              case (PC_DUTY_CYCLE_PER): device_name = "PC_DUTY_CYCLE_PER"; break;
              case (PC_TEMP_AN1): device_name = "PC_TEMP_AN1"; break;
              case (PC_TEMP_AN2): device_name = "PC_TEMP_AN2"; break;
              case (PC_TEMP_DGP): device_name = "PC_TEMP_DGP"; break;
              case (PC_TEMP_ICP): device_name = "PC_TEMP_ICP"; break;
              case (PC_FREQ_VCC): device_name = "PC_FREQ_VCC"; break;
              case (PC_FREQ_PWM): device_name = "PC_FREQ_PWM"; break;
              case (PC_RAM_ICP): device_name = "PC_RAM_ICP"; break;
              case (PC_TEMP_OW_1): device_name = "PC_TEMP_OW_1"; break;
              case (PC_TEMP_OW_2): device_name = "PC_TEMP_OW_2"; break;
              case (PC_TEMP_I2C_1): device_name = "PC_TEMP_I2C_1"; break;
              case (PC_TEMP_I2C_2): device_name = "PC_TEMP_I2C_2"; break;
              case (FC_FAN_CONTROL_1): device_name = "FC_FAN_CONTROL_1 (OVD_OFF/OVD_ON)"; break;
              case (FC_FAN_CONTROL_2): device_name = "FC_FAN_CONTROL_2 (MAN/AUTO)"; break;
              case (FC_VCC_FAN_1): device_name = "FC_VCC_FAN_1"; break;
              case (FC_VCC_FAN_2): device_name = "FC_VCC_FAN_2"; break;
              case (FC_VCC_ICF): device_name = "FC_VCC_ICF (BOTTOM)"; break;
              case (FC_FAN_MODE_1): device_name = "FC_FAN_MODE_1 (VCC_1/PWM_1)"; break;
              case (FC_FAN_RPM_1): device_name = "FC_FAN_RPM_1"; break;
              case (FC_FAN_RPM_2): device_name = "FC_FAN_RPM_2"; break;
              case (FC_FAN_RPM_3): device_name = "FC_FAN_RPM_3"; break;
              case (FC_FAN_RPM_4): device_name = "FC_FAN_RPM_4"; break;
              case (FC_DUTY_CYCLE_PER_1): device_name = "FC_DUTY_CYCLE_PER_1"; break;
              case (FC_FAN_MODE_2): device_name = "FC_FAN_MODE_2 (VCC_2/PWM_2)"; break;
              case (FC_FAN_RPM_5): device_name = "FC_FAN_RPM_5"; break;
              case (FC_FAN_RPM_6): device_name = "FC_FAN_RPM_6"; break;
              case (FC_DUTY_CYCLE_PER_2): device_name = "FC_DUTY_CYCLE_PER_2"; break;
              case (FC_TEMP_AN3): device_name = "FC_TEMP_AN3"; break;
              case (FC_TEMP_AN4): device_name = "FC_TEMP_AN4"; break;
              case (FC_TEMP_DGF): device_name = "FC_TEMP_DGF"; break;
              case (FC_TEMP_ICF): device_name = "FC_TEMP_ICF (TOP)"; break;
              case (FC_FREQ_VCC_1): device_name = "FC_FREQ_VCC_1"; break;
              case (FC_FREQ_PWM_1): device_name = "FC_FREQ_PWM_1"; break;
              case (FC_FREQ_VCC_2): device_name = "FC_FREQ_VCC_2"; break;
              case (FC_FREQ_PWM_2): device_name = "FC_FREQ_PWM_2"; break;
              case (FC_RAM_ICF): device_name = "FC_RAM_ICF (BOTTOM)"; break;
              case (FC_TEMP_OW_3): device_name = "FC_TEMP_OW_3"; break;
              case (FC_TEMP_OW_4): device_name = "FC_TEMP_OW_4"; break;
              case (FC_TEMP_I2C_3): device_name = "FC_TEMP_I2C_3"; break;
              case (FC_TEMP_I2C_4): device_name = "FC_TEMP_I2C_4"; break;
            }

            print_Debug("device_name: " + device_name);

            print_Debug("device_type: " + device_type);

            print_Debug("device_CRC: " + device_CRC);
      
            print_Debug("device_data: " + device_data);

            checkString = "";

            device_name = "";
          }

          delay (10);
        }
      }  
    }
  }
}


void mouseMoved() {
  
  if (mouseX >= 178 && mouseX <=192 && mouseY >= 13 && mouseY <= 32) {

    button_hover_remove = true;
    image(button_hover, 178, 13);

    } else {

    if (button_hover_remove) {
      button_hover_remove = false;
      image(button_image, 178, 13);
    }
  }
}


void mousePressed(){

  if (mouseX >= 178 && mouseX <=192 && mouseY >= 13 && mouseY <= 32) {

    if (mouseButton == LEFT) exit();

    if (mouseButton == RIGHT) {

      frame.setLocation(WINDOW_POSITION_X, WINDOW_POSITION_Y);

      image(button_image, 178, 13);
      
    }

  } else if (mouseX >= 14 && mouseX <= 90 && mouseY >= 14 && mouseY <= 26) {


    if (mouseButton == LEFT) popup.setVisible(false);

    if (mouseButton == RIGHT) {

      popup.setLocation(frame.getX() + mouseX, frame.getY() + mouseY);

      popup.setVisible(true);

    }

  } else {

    popup.setVisible(false);

    //calculate screen mouse positions before dragging  
    p_global_mouse_x = frame.getLocation().x + mouseX;
    p_global_mouse_y = frame.getLocation().y + mouseY;

  }
}


void mouseDragged() {

  if ((mouseButton == LEFT) && (window_lock == false)) {  
    //get x+y position of the frame
    pos_x = frame.getLocation().x;
    pos_y = frame.getLocation().y;

    //calculate screen mouse positions
    global_mouse_x = (pos_x + mouseX);
    global_mouse_y = (pos_y + mouseY);

    //screen x+y movement of mouse
    pos_x += (global_mouse_x - p_global_mouse_x);  
    pos_y += (global_mouse_y - p_global_mouse_y);

    //set new frame possition
    if (CONSTRAIN_FRAME) {
      pos_x = constrain(pos_x, 0, (displayWidth - WINDOW_WIDTH));    // CONSTRAIN_FRAME_X
      pos_y = constrain(pos_y, 0, (displayHeight - (WINDOW_HEIGHT + 30)));    // CONSTRAIN_FRAME_Y
    }

    frame.setLocation(pos_x, pos_y); 

    // remember the last global position
    p_global_mouse_x = global_mouse_x;  
    p_global_mouse_y = global_mouse_y;
  }
}


void keyPressed() {

  if (key == ESC) key = 0;
}


public void exit() {                     // APP_EXIT

  if (TDPC_connected) portOne.stop();
  if (TDFC_connected) portTwo.stop();
  if (frame_in_place) frame_in_place = false;
  if (sensor_mode_on) sensor_frame.sensor_frame_quit();
  if (debug_mode_on) debug_quit = true;
  check_Image_Cache();
  try {
    tray.remove(trayIcon);

  } catch (Exception e) {

    print_Debug("TrayIcon could not be removed");
  }
  super.exit();
}


void update_System_Status() {                  // UPDATE_SYSTEM_STATUS

  if (no_general_data) current_system_status = 4;
  else if (no_data_yet) current_system_status = 3;
  else if (system_alarm) current_system_status = 2;
  else if ((system_warning_control) && (system_warning)) current_system_status = 1;
  else current_system_status = 0;

  if (current_system_status != previous_system_status) {
    fill(0, 0, 0);
    rect(124, 39, 69, 14);
    textFont(font3, 12);
    switch (current_system_status) {

      case (0):         // OK
        fill(0, 255, 0);
        text("OK", 189, 50);
        break;
      case (1):         // WARNING
        fill(255, 117, 24);
        text("WARNING", 189, 50);
        break;
      case (2):        // ALARM
        fill(255, 0, 0);
        text("ALARM", 189, 50);
        break;
      case (3):         // NO_DATA_YET
        textFont(font2, 12);
        fill(255, 255, 255);
        text("-", 189, 50);
        break;
      case (4):         // NO_GENERAL_DATA
        fill(255, 0, 0);
        text("NO DATA", 189, 50);
        break;
    }
    noFill();
    previous_system_status = current_system_status;
  }
}


boolean compare_CRC() {                  // COMPARE_CRC

  int raw_data = 0; 
  int new_crc = 0; 
  boolean crc_result = false;

  switch (device_type) { 

    case (PC_SYSTEM_STATUS): raw_data = int(device_data); break;     // SYSTEM_STATUS (OK/ALARM)
    case (PC_PUMP_CONTROL_1): raw_data = int(device_data); break;     // PUMP_CONTROL_1 (OVD_OFF/OVD_ON)
    case (PC_PUMP_CONTROL_2): raw_data = int(device_data); break;     // PUMP_CONTROL_2 (MAN/AUTO)
    case (PC_VCC_PUMP): raw_data = int(float(device_data) * 1000); break;   // VCC_PUMP
    case (PC_VCC_ICP): raw_data = int(float(device_data) * 1000); break;   // VCC_ICP
    case (PC_PUMP_MODE): raw_data = int(device_data); break;     // PUMP_MODE (VCC/PWM)
    case (PC_PUMP_RPM_1): raw_data = int(device_data); break;     // PUMP_RPM_1
    case (PC_PUMP_RPM_2): raw_data = int(device_data); break;     // PUMP_RPM_2
    case (PC_PSU_RPM): raw_data = int(device_data); break;       // PSU_RPM
    case (PC_PUMP_FLOW): raw_data = int(float(device_data) * 100); break;   // PUMP_FLOW
    case (PC_DUTY_CYCLE_PER): raw_data = int(device_data); break;     // PUMP_DUTY_CYCLE_PER
    case (PC_TEMP_AN1): raw_data = int(float(device_data) * 10); break;  // TEMP_AN1
    case (PC_TEMP_AN2): raw_data = int(float(device_data) * 10); break;  // TEMP_AN2
    case (PC_TEMP_DGP): raw_data = int(float(device_data) * 10); break;  // TEMP_DGP
    case (PC_TEMP_ICP): raw_data = int(float(device_data) * 10); break;  // TEMP_ICP
    case (PC_FREQ_VCC): raw_data = int(float(device_data) * 1000); break;   // PUMP_FREQ_VCC
    case (PC_FREQ_PWM): raw_data = int(float(device_data) * 1000); break;   // PUMP_FREQ_PWM
    case (PC_RAM_ICP): raw_data = int(device_data); break;      // RAM_ICP
    case (PC_TEMP_OW_1): raw_data = int(float(device_data) * 10); break;  // TEMP_OW_1
    case (PC_TEMP_OW_2): raw_data = int(float(device_data) * 10); break;  // TEMP_OW_2
    case (PC_TEMP_I2C_1): raw_data = int(float(device_data) * 10); break;  // TEMP_I2C_1
    case (PC_TEMP_I2C_2): raw_data = int(float(device_data) * 10); break;  // TEMP_I2C_2
    case (FC_FAN_CONTROL_1): raw_data = int(device_data); break;     // FAN_CONTROL_1 (OVD_OFF/OVD_ON)
    case (FC_FAN_CONTROL_2): raw_data = int(device_data); break;     // FAN_CONTROL_2 (MAN/AUTO)
    case (FC_VCC_FAN_1): raw_data = int(float(device_data) * 1000); break;   // VCC_FAN_1
    case (FC_VCC_FAN_2): raw_data = int(float(device_data) * 1000); break;   // VCC_FAN_2
    case (FC_VCC_ICF): raw_data = int(float(device_data) * 1000); break;   // VCC_ICF
    case (FC_FAN_MODE_1): raw_data = int(device_data); break;     // FAN_MODE_1 (VCC_1/PWM_1)
    case (FC_FAN_RPM_1): raw_data = int(device_data); break;     // FAN_RPM_1
    case (FC_FAN_RPM_2): raw_data = int(device_data); break;     // FAN_RPM_2
    case (FC_FAN_RPM_3): raw_data = int(device_data); break;     // FAN_RPM_3
    case (FC_FAN_RPM_4): raw_data = int(device_data); break;     // FAN_RPM_4
    case (FC_DUTY_CYCLE_PER_1): raw_data = int(device_data); break;   // FAN_DUTY_CYCLE_PER_1
    case (FC_FAN_MODE_2): raw_data = int(device_data); break;     // FAN_MODE_2 (VCC_2/PWM_2)
    case (FC_FAN_RPM_5): raw_data = int(device_data); break;     // FAN_RPM_1
    case (FC_FAN_RPM_6): raw_data = int(device_data); break;     // FAN_RPM_2
    case (FC_DUTY_CYCLE_PER_2): raw_data = int(device_data); break;   // FAN_DUTY_CYCLE_PER_2
    case (FC_TEMP_AN3): raw_data = int(float(device_data) * 10); break;  // TEMP_AN3
    case (FC_TEMP_AN4): raw_data = int(float(device_data) * 10); break;  // TEMP_AN4
    case (FC_TEMP_DGF): raw_data = int(float(device_data) * 10); break;  // TEMP_DGF
    case (FC_TEMP_ICF): raw_data = int(float(device_data) * 10); break;  // TEMP_ICF
    case (FC_FREQ_VCC_1): raw_data = int(float(device_data) * 1000); break; // FAN_FREQ_VCC_1
    case (FC_FREQ_PWM_1): raw_data = int(float(device_data) * 1000); break; // FAN_FREQ_PWM_1
    case (FC_FREQ_VCC_2): raw_data = int(float(device_data) * 1000); break; // FAN_FREQ_VCC_2
    case (FC_FREQ_PWM_2): raw_data = int(float(device_data) * 1000); break; // FAN_FREQ_PWM_2
    case (FC_RAM_ICF): raw_data = int(device_data); break;      // RAM_ICF
    case (FC_TEMP_OW_3): raw_data = int(float(device_data) * 10); break;  // TEMP_OW_3
    case (FC_TEMP_OW_4): raw_data = int(float(device_data) * 10); break;  // TEMP_OW_4
    case (FC_TEMP_I2C_3): raw_data = int(float(device_data) * 10); break;  // TEMP_I2C_3
    case (FC_TEMP_I2C_4): raw_data = int(float(device_data) * 10); break;  // TEMP_I2C_4
  }
  new_crc = (device_type + raw_data);
  if (new_crc <= 9999) new_crc += 9999;
  if (device_CRC == new_crc) crc_result = true;
  else crc_result = false;

  if (debug_mode_on) {

    print_Debug("new_crc: " + new_crc);

    print_Debug("crc_result: " + crc_result);

    print_Debug("--------------------------");
  }

  return crc_result;
}


void create_Header() {

  textFont(font1, 14);
  textAlign(LEFT);
  fill(255, 255, 255);
  text("TEARDROP", 20, 28);
  noFill(); 
}


void create_Device_List() {

  textFont(font2, 12);
  textAlign(LEFT);
  fill(255, 255, 255);

  text("SYSTEM STATUS", 20, 50);   // SYSTEM_STATUS (OK/WARNING/ALARM/NO_DATA)

  // PUMP CONTROLLER

  text("PUMP CONTROL", 20, 70);    // PUMP_CONTROL (MANUAL/AUTO/OVD)
  text("PUMP VCC", 20, 85);        // VCC_PUMP
  text("ICP VCC", 20, 100);        // VCC_ICP

  text("PUMP MODE", 20, 120);      // PUMP_MODE (VCC/PWM)
    text("PUMP #1", 20, 135);      // PUMP_RPM_1
  text("PUMP #2", 20, 150);        // PUMP_RPM_2
  text("FLOW RATE", 20, 165);      // PUMP_FLOW
  text("DUTY MONITOR", 20, 180);   // PUMP_DUTY_CYCLE_BAR
  text("DUTY PERCENT", 20, 195);   // PUMP_DUTY_CYCLE_PER

  text("AN TEMP #1", 20, 215);     // TEMP_AN1
  text("AN TEMP #2", 20, 230);     // TEMP_AN2
  text("DGP TEMP", 20, 245);       // TEMP_DGP
  text("ICP TEMP", 20, 260);       // TEMP_ICP

  text("VCC DRIVE", 20, 280);      // PUMP_FREQ_VCC
  text("PWM DRIVE", 20, 295);      // PUMP_FREQ_PWM

  text("ICP COM PORT", 20, 315);   // COM_PORT_ICP
  text("ICP BAUD RATE", 20, 330);  // BAUD_RATE_ICP
  text("ICP RAM", 20, 345);        // RAM_ICP

  // FAN CONTROLLER

  text("FAN CONTROL", 20, 365);    // FAN_CONTROL (MANUAL/AUTO/OVD)
  text("FAN VCC #1", 20, 380);     // VCC_FAN_1
  text("FAN VCC #2", 20, 395);     // VCC_FAN_2
  text("ICF VCC", 20, 410);        // VCC_ICF (BOTTOM)

  text("FAN MODE #1", 20, 430);    // FAN_MODE_1 (VCC_1/PWM_1)
  text("FAN #1", 20, 445);         // FAN_RPM_1
  text("FAN #2", 20, 460);         // FAN_RPM_2
  text("FAN #3", 20, 475);         // FAN_RPM_3
  text("FAN #4", 20, 490);         // FAN_RPM_4
  text("DUTY MONITOR", 20, 505);   // FAN_DUTY_CYCLE_BAR_1
  text("DUTY PERCENT", 20, 520);   // FAN_DUTY_CYCLE_PER_1
  
  text("FAN MODE #2", 20, 540);    // FAN_MODE_2 (VCC_2/PWM_2)
  text("FAN #5", 20, 555);         // FAN_RPM_5
  text("FAN #6", 20, 570);         // FAN_RPM_6
  text("DUTY MONITOR", 20, 585);   // FAN_DUTY_CYCLE_BAR_2
  text("DUTY PERCENT", 20, 600);   // FAN_DUTY_CYCLE_PER_2
 
  text("FAN PSU", 20, 620);        // PSU_RPM
 
  text("AN TEMP #3", 20, 640);     // TEMP_AN3
  text("AN TEMP #4", 20, 655);     // TEMP_AN4
  text("DGF TEMP ", 20, 670);      // TEMP_DGF
  text("ICF TEMP", 20, 685);       // TEMP_ICF (TOP)

  text("VCC DRIVE #1", 20, 705);   // FAN_VCC_1  
  text("PWM DRIVE #1", 20, 720);   // FAN_PWM_1
  text("VCC DRIVE #2", 20, 735);   // FAN_VCC_2
  text("PWM DRIVE #2", 20, 750);   // FAN_PWM_2

  text("ICF COM PORT", 20, 770);   // COM_PORT_ICF
  text("ICF BAUD RATE", 20, 785);  // BAUD_RATE_ICF
  text("ICF RAM", 20, 800);        // RAM_ICF (BOTTOM)

  noFill();
}  


void create_Duty_Bar() {

  fill(35, 74, 104);  
  rect (138, 172, 54, 8);         // PUMP_DUTY_CYCLE_BAR  
  rect (138, 497, 54, 8);         // FAN_DUTY_CYCLE_BAR_1
  rect (138, 577, 54, 8);         // FAN_DUTY_CYCLE_BAR_2
  noFill();
}


void create_Units() {

  // PUMP CONTROLLER

  textFont(font2, 12);
  textAlign(RIGHT);
  fill(255, 255, 255);

  text("V", 190, 85);      // VCC_PUMP
  text("V", 190, 100);     // VCC_ICP

  text("RPM", 190, 135);   // PUMP_RPM_1
  text("RPM", 190, 150);   // PUMP_RPM_2
  text("LPM", 190, 165);   // PUMP_FLOW
  text("%", 190, 195);     // PUMP_DUTY_CYCLE_PER

  text("°C", 190, 215);    // TEMP_AN1
  text("°C", 190, 230);    // TEMP_AN2
  text("°C", 190, 245);    // TEMP_DGP
  text("°C", 190, 260);    // TEMP_ICP

  text("KHz", 190, 280);   // PUMP_FREQ_VCC
  text("KHz", 190, 295);   // PUMP_FREQ_PWM

  text("Bd", 190, 330);    // BAUD_RATE_ICP
  text("Bt", 190, 345);    // RAM_ICP

  // FAN CONTROLLER

  text("V", 190, 380);     // VCC_FAN_1
  text("V", 190, 395);     // VCC_FAN_2
  text("V", 190, 410);     // VCC_IC (BOTTOM)

  text("RPM", 190, 445);   // FAN_RPM_1
  text("RPM", 190, 460);   // FAN_RPM_2
  text("RPM", 190, 475);   // FAN_RPM_3
  text("RPM", 190, 490);   // FAN_RPM_4
  
  text("%", 190, 520);     // DUTY_CYCLE_1 (PERCENT)
  
  text("RPM", 190, 555);   // FAN_RPM_5
  text("RPM", 190, 570);   // FAN_RPM_6

  text("%", 190, 600);     // DUTY_CYCLE_2 (PERCENT)
 
  text("RPM", 190, 620);   // FAN_PSU

  text("°C", 190, 640);    // TEMP_AN3
  text("°C", 190, 655);    // TEMP_AN4
  text("°C", 190, 670);    // TEMP_DGF
  text("°C", 190, 685);    // TEMP_ICF (TOP)

  text("KHz", 190, 705);   // FAN_FREQ_VCC_1
  text("KHz", 190, 720);   // FAN_FREQ_PWM_1
  text("KHz", 190, 735);   // FAN_FREQ_VCC_2
  text("KHz", 190, 750);   // FAN_FREQ_PWM_2
  
  text("Bd", 190, 785);    // BAUD_RATE_ICF
  text("Bt", 190, 800);    // RAM_ICF (BOTTOM)

  noFill(); 
}


void create_Inivital_Values() {

  textAlign(RIGHT);
  fill(255, 255, 255);

  textFont(font2, 12);
    text("-", 189, 50);      // SYSTEM_STATUS (OK/WARNING/ALARM/NO_DATA)

  // PUMP_CONTROLLER

  text("-", 189, 70);        // PUMP_CONTROL (MAN/AUTO/OVD)

  textFont(font4, 11);
  text("0.000", 174, 85);    // VCC_PUMP
  text("0.000", 174, 100);   // VCC_ICP

  textFont(font2, 12);
  text("-", 189, 120);       // PUMP_MODE (VCC/PWM)

  textFont(font4, 11); 
  text("0", 162, 135);       // PUMP_RPM_1
  text("0", 162, 150);       // PUMP_RPM_2
  text("0.00", 162, 165);    // PUMP_FLOW

  text("0", 179, 195);       // PUMP_DUTY_CYCLE_PER

  text("0.0", 169, 215);     // TEMP_AN1
  text("0.0", 169, 230);     // TEMP_AN2
  text("0.0", 169, 245);     // TEMP_DGP
  text("0.0", 169, 260);     // TEMP_ICP

  text("0.000", 164, 280);   // PUMP_FREQ_VCC
  text("0.000", 164, 295);   // PUMP_FREQ_PWM

  textFont(font2, 12);
  text(pump_com_port, 192, 315);  // COM_PORT_ICP

  textFont(font4, 11);
  text(pump_baud_rate, 172, 330);  // BAUD_RATE_ICP
  text("0", 172, 345);       // RAM_ICP

  // FAN_CONTROLLER

  textFont(font2, 12);
  text("-", 189, 365);         // FAN_CONTROL (MAN/AUTO/OVD)

  textFont(font4, 11);
  text("0.000", 174, 380);      // VCC_FAN_1
  text("0.000", 174, 395);      // VCC_FAN_2
  text("0.000", 174, 410);      // VCC_ICF (BOTTOM)

  textFont(font2, 12);
  text("-", 189, 430);         // FAN_MODE_1 (VCC_1/PWM_1)

  textFont(font4, 11); 
  text("0", 162, 445);         // FAN_RPM_1
  text("0", 162, 460);         // FAN_RPM_2
  text("0", 162, 475);         // FAN_RPM_3
  text("0", 162, 490);         // FAN_RPM_4

  text("0", 179, 520);         // FAN_DUTY_CYCLE_PER_1

  textFont(font2, 12);
  text("-", 189, 540);         // FAN_MODE_2 (VCC_2/PWM_2)

  textFont(font4, 11); 
  text("0", 162, 555);         // FAN_RPM_5
  text("0", 162, 570);         // FAN_RPM_6

  text("0", 179, 600);         // FAN_DUTY_CYCLE PER_2
 
  text("0", 162, 620);         // PSU_RPM
 
  text("0.0", 169, 640);       // TEMP_AN3
  text("0.0", 169, 655);       // TEMP_AN4
  text("0.0", 169, 670);       // TEMP_DGP
  text("0.0", 169, 685);       // TEMP_ICP (TOP)
 
  text("0.000", 164, 705);     // FAN_FREQ_VCC_1
  text("0.000", 164, 720);     // FAN_FREQ_PWM_1
  text("0.000", 164, 735);     // FAN_FREQ_VCC_2
  text("0.000", 164, 750);     // FAN_FREQ_PWM_2
  
  textFont(font2, 12);
  text(fan_com_port, 192, 770);  // COM_PORT_ICF

  textFont(font4, 11);
  text(fan_baud_rate, 172, 785);   // BAUD_RATE_ICF
  text("0", 172, 800);             // RAM_ICF (BOTTOM)  
 
  noFill();
}


void read_Data() {                    // READ_SERIAL_DATA

  system_warning = false;

  textAlign(RIGHT);
  switch (device_type) { 

    // PUMP CONTROLLER

    case (PC_SYSTEM_STATUS):                // SYSTEM_STATUS (OK/ALARM)

      if (int(device_data) == 0) system_alarm = false;      // OK
        
      if (int(device_data) == 1) system_alarm = true;       // ALARM
      
      break;

    case (PC_PUMP_CONTROL_1):                // PUMP_CONTROL_1 (OVD_OFF/OVD_ON)

      if (int(device_data) == 0) pump_overdrive = false;      // PUMP_OVD_OFF

      if (int(device_data) == 1) {            // PUMP_OVD_ON
        pump_overdrive = true;
        fill(0, 0, 0);
         rect(124, 59, 69, 14);
        textFont(font3, 12);
        fill(255, 255, 0);
        text("OVERDRIVE", 189, 70);
        noFill();
       }
            break;

    case (PC_PUMP_CONTROL_2):                // PUMP_CONTROL_2 (MAN/AUTO)

      if (!pump_overdrive) {                 // PUMP_OVD_OFF

        if (int(device_data) == 0) {         // MAN
          fill(0, 0, 0);
          rect(124, 59, 69, 14);
          textFont(font3, 12);
          fill(90, 100, 20);
          text("MANUAL", 189, 70);
          noFill();
        }

        if (int(device_data) == 1) {          // AUTO
          fill(0, 0, 0);
          rect(124, 59, 69, 14);
          textFont(font3, 12);
          fill(40, 90, 150);
          text("AUTO", 189, 70);
          noFill();
        }
      }
             break;

    case (PC_VCC_PUMP):                      // VCC_PUMP

      if ((float(device_data) >= 0.0) && (float(device_data) < 20.0)) {
        fill(0, 0, 0);
        rect(125, 74, 50, 14);
        textFont(font4, 11);
        if ((float(device_data) < 6.5) || (float(device_data) > 12.6)) {  // WARNING/(ALARM)
          if ((float(device_data) < 5.5) || (float(device_data) > 13.0)) fill(255, 0, 0);
          else fill(255, 117, 24);
          warning_flag[0] = true;
        } else {              // OK
          fill(255, 255, 255);
          warning_flag[0] = false;
        }
        text(device_data, 174, 85);
        noFill();
      }
      break;

    case (PC_VCC_ICP):                  // VCC_ICP    

      if ((float(device_data) >= 0.0) && (float(device_data) < 10.0)) {
        fill(0, 0, 0);
        rect(125, 89, 50, 14);
        textFont(font4, 11);
        if ((float(device_data) < 4.65) || (float(device_data) > 5.25)) {  // WARNING/(ALARM)
          if ((float(device_data) < 4.5) || (float(device_data) > 5.5)) fill(255, 0, 0);
          else fill(255, 117, 24);
          warning_flag[1] = true;
        } else {              // OK
          fill(255, 255, 255);
          warning_flag[1] = false;
        }
        text(device_data, 174, 100);
        noFill();
      }
      break;

    case (PC_PUMP_MODE):                  // PUMP_MODE (VCC/PWM)

      if (int(device_data) == 0) {            // VCC
        fill(0, 0, 0);
        rect(124, 109, 69, 14);
        textFont(font3, 12);
        fill(216, 107, 0);
        text("VCC", 189, 120);
        noFill();
      }

      if (int(device_data) == 1) {            // PWM
        fill(0, 0, 0);
        rect(124, 109, 69, 14);
        textFont(font3, 12);
        fill(140, 10, 150);
        text("P", 174, 120);
        text("W", 182, 120);
        text("M", 190, 120);
        noFill();
      }
      break;

    case (PC_PUMP_RPM_1):                  // PUMP_RPM_1

      if ((int(device_data) >= 0) && (int(device_data) <= 5000)) {
        fill(0, 0, 0);
        rect(116, 124, 48, 14);
        textFont(font4, 11);
        if (int(device_data) < 600) {          // WARNING/ALARM
          if (int(device_data) < 500) fill(255, 0, 0); 
          else fill(255, 117, 24);
          warning_flag[2] = true;
        } else {              // OK
          fill(255, 255, 255);
          warning_flag[2] = false;
        }
        text(device_data , 162, 135);
        noFill();
      }
      break;

    case (PC_PUMP_RPM_2):                  // PUMP_RPM_2

      if ((int(device_data) >= 0) && (int(device_data) <= 5000)) {
        fill(0, 0, 0);
        rect(116, 139, 48, 14);
        textFont(font4, 11);
        if (int(device_data) < 600) {          // WARNING/ALARM
          if (int(device_data) < 400) fill(255, 0, 0); 
          else fill(255, 117, 24);
          warning_flag[3] = true;
        } else {              // OK
          fill(255, 255, 255);
          warning_flag[3] = false;
        }
        text(device_data , 162, 150);
        noFill();
      }
      break;

    case (PC_PSU_RPM):                  // PSU_RPM

      if ((int(device_data) >= 0) && (int(device_data) <= 5000)) {
        fill(0, 0, 0);
        rect(116, 609, 48, 14);
        textFont(font4, 11);
        if (int(device_data) <= 600) {          // WARNING
          if (int(device_data) <= 500) fill(255, 0, 0); 
          else fill(255, 117, 24);
          warning_flag[4] = true;
        } else {              // OK
          fill(255, 255, 255);
          warning_flag[4] = false;
        }
        text(device_data , 162, 620);
        noFill();
      }
      break;

    case (PC_PUMP_FLOW):                  // PUMP_FLOW

      if ((float(device_data) >= 0.00) && (float(device_data) <= 25.00)) {
        fill(0, 0, 0);
         rect(118 ,154, 48, 14);
        textFont(font4, 11);
        if ((float(device_data) < 5.50) || (float(device_data) > 20.0)) { // WARNING/ALARM
          if ((float(device_data) < 4.00) || (float(device_data) > 20.0)) fill(255, 0, 0);
          else fill(255, 117, 24);
          warning_flag[5] = true;
        } else {              // OK
          fill(255, 255, 255);
          warning_flag[5] = false;
        }
        text(device_data, 162, 165);
        noFill();
       }
      break;

    case (PC_DUTY_CYCLE_PER):                // PUMP_DUTY_CYCLE

      if ((int(device_data) >= 0) && (int(device_data) <= 100)) {

        fill(35, 74, 104);            // PUMP_DUTY_CYCLE_BAR 
        rect (138, 172, 54, 8);
        pump_duty_bar = map(float(device_data), 0, 100, 0, 54);
        fill(55, 129, 186);
        rect(138, 172, pump_duty_bar, 8);

        fill(0, 0, 0);              // PUMP_DUTY_CYCLE_PER
        rect(155 ,184, 25, 14);
        textFont(font4, 11);
        fill(255, 255, 255);
        text(device_data, 179, 195);
        noFill();
      }
      break;

    case (PC_TEMP_AN1):                  // TEMP_AN1

      if ((float(device_data) >= 0) && (float(device_data) <= 150.0)) {
        fill(0, 0, 0);
        rect(128, 204, 44, 14);
        textFont(font4, 11);
        if ((float(device_data) < 15.0) || (float(device_data) > 50.0)) {  // WARNING/ALARM  
          if ((float(device_data) < 5.0) || (float(device_data) > 55.0)) fill(255, 0, 0);
          else fill(255, 117, 24);
          warning_flag[6] = true;
        } else {              // OK
          fill(255, 255, 255);
          warning_flag[6] = false;
        }
        text(device_data, 169, 215);
        noFill();
      }
      break;

    case (PC_TEMP_AN2):                  // TEMP_AN2

      if ((float(device_data) >= 0) && (float(device_data) <= 150.0)) {
        fill(0, 0, 0);
        rect(128, 219, 44, 14);
        textFont(font4, 11);
        if ((float(device_data) < 15.0) || (float(device_data) > 50.0)) {  // WARNING/ALARM  
          if ((float(device_data) < 5.0) || (float(device_data) > 55.0)) fill(255, 0, 0);
          else fill(255, 117, 24);
          warning_flag[7] = true;
        } else {              // OK
          fill(255, 255, 255);
          warning_flag[7] = false;
        }
        text(device_data, 169, 230);
        noFill();
      }
      break;

    case (PC_TEMP_DGP):                  // TEMP_DGP

      if ((float(device_data) >= 0) && (float(device_data) <= 150.0)) {
        fill(0, 0, 0);
        rect(128, 234, 44, 14);
        textFont(font4, 11);
        if ((float(device_data) < 10.0) || (float(device_data) > 50.0)) {  // WARNING/(ALARM)
          if ((float(device_data) < 5.0) || (float(device_data) > 55.0)) fill(255, 0, 0);
          else fill(255, 117, 24);
          warning_flag[8] = true;
        } else {              // OK
          fill(255, 255, 255);
          warning_flag[8] = false;
        }
        text(device_data, 169, 245);
        noFill();
      }
      break;

    case (PC_TEMP_ICP):                  // TEMP_ICP

      if ((float(device_data) >= 0) && (float(device_data) <= 150.0)) {
        fill(0, 0, 0);
        rect(128, 249, 44, 14);
        textFont(font4, 11);
        if ((float(device_data) < 10.0) || (float(device_data) > 40.0)) {  // WARNING/(ALARM)
          if ((float(device_data) < 5.0) || (float(device_data) > 50.0)) fill(255, 0, 0);
          else fill(255, 117, 24);
          warning_flag[9] = true;
        } else {              // OK
          fill(255, 255, 255);
          warning_flag[9] = false;
        }
        text(device_data, 169, 260);
        noFill();
      }
      break;

          case (PC_FREQ_VCC):                  // PUMP_FREQ_VCC

      if ((float(device_data) >= 0.000) && (float(device_data) <= 60.000)) {
        fill(0, 0, 0);
        rect(120, 269, 48, 14);
        textFont(font4, 11);
        if ((float(device_data) < 24.700) || (float(device_data) > 25.700)) {  // WARNING/(ALARM)
          if ((float(device_data) < 24.500) || (float(device_data) > 25.900)) fill(255, 0, 0);
          else fill(255, 117, 24);
          warning_flag[10] = true;
        } else {              // OK
          fill(255, 255, 255);
          warning_flag[10] = false;
        }
        text(device_data, 164, 280);
        noFill();
      }  
      break;

          case (PC_FREQ_PWM):                  // PUMP_FREQ_PWM

      if ((float(device_data) >= 0.000) && (float(device_data) <= 60.000)) {
        fill(0, 0, 0);
        rect(120, 284, 48, 14);
        textFont(font4, 11);
        if ((float(device_data) < 24.700) || (float(device_data) > 25.700)) {  // WARNING/(ALARM)
          if ((float(device_data) < 24.500) || (float(device_data) > 25.900)) fill(255, 0, 0);
          else fill(255, 117, 24);
          warning_flag[11] = true;
        } else {              // OK
          fill(255, 255, 255);
          warning_flag[11] = false;
        }
        text(device_data, 164, 295);
        noFill();
      }  
      break;

    case (PC_RAM_ICP):                  // RAM_ICP

      if ((int(device_data) >= 0) && (int(device_data) <= 5000)) {
        fill(0, 0, 0);
        rect(125, 334, 48, 14);
        textFont(font4, 11);  
        if (int(device_data) < 1000) {          // WARNING/(ALARM)
          if (int(device_data) < 800) fill(255, 0, 0);
          else fill(255, 117, 24);
          warning_flag[12] = true;
        } else {              // OK
          fill(255, 255, 255);
          warning_flag[12] = false;
        }
        text(device_data, 171, 345);
        noFill();
      }
      break;

    case (PC_TEMP_OW_1):                  // TEMP_OW_1

      if (sensor_mode_on) {

        if ((float(device_data) >= 0) && (float(device_data) <= 150.0)) {
          sensor_applet.fill(0, 0, 0);
          sensor_applet.rect(130, 39, 42, 14);
          sensor_applet.textFont(font4, 11);
          if ((float(device_data) < 15.0) || (float(device_data) > 50.0)) {  // WARNING/ALARM  
            if ((float(device_data) < 5.0) || (float(device_data) > 55.0)) sensor_applet.fill(255, 0, 0);
            else sensor_applet.fill(255, 117, 24);
            warning_flag[13] = true;
          } else {              // OK
            sensor_applet.fill(255, 255, 255);
            warning_flag[13] = false;
          }
          sensor_applet.text(device_data, 169, 50);
          sensor_applet.noFill();
          sensor_applet.repaint();
        }
      }
      break;


    case (PC_TEMP_OW_2):                  // TEMP_OW_2

      if (sensor_mode_on) {

        if ((float(device_data) >= 0) && (float(device_data) <= 150.0)) {
          sensor_applet.fill(0, 0, 0);
          sensor_applet.rect(130, 54, 42, 14);
          sensor_applet.textFont(font4, 11);
          if ((float(device_data) < 15.0) || (float(device_data) > 50.0)) {  // WARNING/ALARM  
            if ((float(device_data) < 5.0) || (float(device_data) > 55.0)) sensor_applet.fill(255, 0, 0);
            else sensor_applet.fill(255, 117, 24);
            warning_flag[14] = true;
          } else {              // OK
            sensor_applet.fill(255, 255, 255);
            warning_flag[14] = false;
          }
          sensor_applet.text(device_data, 169, 65);
          sensor_applet.noFill();
          sensor_applet.repaint();
        }
      }
      break;

    case (PC_TEMP_I2C_1):                  // TEMP_I2C_1

      if (sensor_mode_on) {

        if ((float(device_data) >= 0) && (float(device_data) <= 150.0)) {
          sensor_applet.fill(0, 0, 0);
          sensor_applet.rect(130, 99, 42, 14);
          sensor_applet.textFont(font4, 11);
          if ((float(device_data) < 15.0) || (float(device_data) > 50.0)) {  // WARNING/ALARM  
            if ((float(device_data) < 5.0) || (float(device_data) > 55.0)) sensor_applet.fill(255, 0, 0);
            else sensor_applet.fill(255, 117, 24);
            warning_flag[15] = true;
          } else {              // OK
            sensor_applet.fill(255, 255, 255);
            warning_flag[15] = false;
          }
          sensor_applet.text(device_data, 169, 110);
          sensor_applet.noFill();
          sensor_applet.repaint();
        }
      }
      break;

    case (PC_TEMP_I2C_2):                  // TEMP_I2C_2

      if (sensor_mode_on) {

        if ((float(device_data) >= 0) && (float(device_data) <= 150.0)) {
          sensor_applet.fill(0, 0, 0);
          sensor_applet.rect(130, 114, 42, 14);
          sensor_applet.textFont(font4, 11);
          if ((float(device_data) < 15.0) || (float(device_data) > 50.0)) {  // WARNING/ALARM  
            if ((float(device_data) < 5.0) || (float(device_data) > 55.0)) sensor_applet.fill(255, 0, 0);
            else sensor_applet.fill(255, 117, 24);
            warning_flag[16] = true;
          } else {              // OK
            sensor_applet.fill(255, 255, 255);
            warning_flag[16] = false;
          }
          sensor_applet.text(device_data, 169, 125);
          sensor_applet.noFill();
          sensor_applet.repaint();
        }
      }
      break;


    // FAN CONTROLLER

    case (FC_FAN_CONTROL_1):                // FAN_CONTROL_1 (OVD_OFF/OVD_ON)

      if (int(device_data) == 0) fan_overdrive = false;      // FAN_OVD_OFF

      if (int(device_data) == 1) {            // FAN_OVD_ON
        fan_overdrive = true;
        fill(0, 0, 0);
         rect(124, 354, 69, 14);
        textFont(font3, 12);
        fill(255, 255, 0);
        text("OVERDRIVE", 189, 365);
        noFill();
       }
             break;

    case (FC_FAN_CONTROL_2):                // FAN_CONTROL_2 (MAN/AUTO)

      if (!fan_overdrive) {                      // FAN_OVD_OFF

        if (int(device_data) == 0) {          // MAN
          fill(0, 0, 0);
          rect(124, 354, 69, 14);
          textFont(font3, 12);
          fill(90, 100, 20);
          text("MANUAL", 189, 365);
          noFill();
        }

        if (int(device_data) == 1) {          // AUTO
          fill(0, 0, 0);
          rect(124, 354, 69, 14);
          textFont(font3, 12);
          fill(40, 90, 150);
          text("AUTO", 189, 365);
          noFill();
        }
      }
             break;

    case (FC_VCC_FAN_1):                  // VCC_FAN_1

      if ((float(device_data) >= 0.0) && (float(device_data) < 20.0)) {
        fill(0, 0, 0);
        rect(125, 369, 50, 14);
        textFont(font4, 11);
        if ((float(device_data) < 6.5) || (float(device_data) > 12.60)) {  // WARNING/(ALARM)
          if ((float(device_data) < 5.5) || (float(device_data) > 13.0)) fill(255, 0, 0);
          else fill(255, 117, 24);
          warning_flag[17] = true;
        } else {              // OK
          fill(255, 255, 255);
          warning_flag[17] = false;
        }
        text(device_data, 174, 380);
        noFill();
      }
      break;


    case (FC_VCC_FAN_2):                  // VCC_FAN_2

      if ((float(device_data) >= 0.0) && (float(device_data) < 20.0)) {
        fill(0, 0, 0);
        rect(125, 384, 50, 14);
        textFont(font4, 11);
        if ((float(device_data) < 6.5) || (float(device_data) > 12.60)) {  // WARNING/(ALARM)
          if ((float(device_data) < 5.5) || (float(device_data) > 13.0)) fill(255, 0, 0);
          else fill(255, 117, 24);
          warning_flag[18] = true;
        } else {              // OK
          fill(255, 255, 255);
          warning_flag[18] = false;
        }
        text(device_data, 174, 395);
        noFill();
      }
      break;


    case (FC_VCC_ICF):                  // VCC_ICF (BOTTOM)    

      if ((float(device_data) >= 0.0) && (float(device_data) < 10.0)) {
        fill(0, 0, 0);
        rect(125, 399, 50, 14);
        textFont(font4, 11);
        if ((float(device_data) < 4.25) || (float(device_data) > 5.25)) {  // WARNING/(ALARM)
          if ((float(device_data) < 4.00) || (float(device_data) > 5.5)) fill(255, 0, 0);
          else fill(255, 117, 24);
          warning_flag[19] = true;
        } else {              // OK
          fill(255, 255, 255);
          warning_flag[19] = false;
        }
        text(device_data, 174, 410);
        noFill();
      }
      break;

    case (FC_FAN_MODE_1):                  // FAN_MODE_1 (VCC_1/PWM_1)

      if (int(device_data) == 0) {            // VCC_1
        fill(0, 0, 0);
        rect(124, 419, 69, 14);
        textFont(font3, 12);
        fill(216, 107, 0);
        text("VCC", 189, 430);
        noFill();
      }

      if (int(device_data) == 1) {            // PWM_1
        fill(0, 0, 0);
        rect(124, 419, 69, 14);
        textFont(font3, 12);
        fill(140, 10, 150);
        text("P", 174, 430);
        text("W", 182, 430);
        text("M", 190, 430);
        noFill();
      }
      break;

    case (FC_FAN_RPM_1):                  // FAN_RPM_1

      if ((int(device_data) >= 0) && (int(device_data) <= 5000)) {
        fill(0, 0, 0);
        rect(116, 434, 48, 14);
        textFont(font4, 11);
        if (int(device_data) < 600) {          // WARNING/(ALARM)
          if (int(device_data) < 500) fill(255, 0, 0); 
          else fill(255, 117, 24);
          warning_flag[20] = true;
        } else {              // OK
          fill(255, 255, 255);
          warning_flag[20] = false;
        }
        text(device_data , 162, 445);
        noFill();
      }
      break;

    case (FC_FAN_RPM_2):                  // FAN_RPM_2

      if ((int(device_data) >= 0) && (int(device_data) <= 5000)) {
        fill(0, 0, 0);
        rect(116, 449, 48, 14);
        textFont(font4, 11);
        if (int(device_data) < 600) {          // WARNING/(ALARM)
          if (int(device_data) < 500) fill(255, 0, 0); 
          else fill(255, 117, 24);
          warning_flag[21] = true;
        } else {              // OK
          fill(255, 255, 255);
          warning_flag[21] = false;
        }
        text(device_data , 162, 460);
        noFill();
      }
      break;

    case (FC_FAN_RPM_3):                  // FAN_RPM_3

      if ((int(device_data) >= 0) && (int(device_data) <= 5000)) {
        fill(0, 0, 0);
        rect(116, 464, 48, 14);
        textFont(font4, 11);
        if (int(device_data) < 600) {          // WARNING/(ALARM)
          if (int(device_data) < 500) fill(255, 0, 0); 
          else fill(255, 117, 24);
          warning_flag[22] = true;
        } else {              // OK
          fill(255, 255, 255);
          warning_flag[22] = false;
        }
        text(device_data , 162, 475);
        noFill();
      }
      break;

    case (FC_FAN_RPM_4):                  // FAN_RPM_4

      if ((int(device_data) >= 0) && (int(device_data) <= 5000)) {
        fill(0, 0, 0);
        rect(116, 479, 48, 14);
        textFont(font4, 11);
        if (int(device_data) < 600) {          // WARNING/(ALARM)
          if (int(device_data) < 500) fill(255, 0, 0); 
          else fill(255, 117, 24);
          warning_flag[23] = true;
        } else {
          fill(255, 255, 255);          // OK
          warning_flag[23] = false;
        }
        text(device_data , 162, 490);
        noFill();
      }
      break;

    case (FC_DUTY_CYCLE_PER_1):                // FAN_DUTY_CYCLE_1

      if ((int(device_data) >= 0) && (int(device_data) <= 100)) {

        fill(35, 74, 104);            // FAN_DUTY_CYCLE_BAR_1
        rect (138, 497, 54, 8);
        fan_duty_bar_1 = map(float(device_data), 0, 100, 0, 54);
        fill(55, 129, 186);
        rect(138, 497, fan_duty_bar_1, 8);

        fill(0, 0, 0);              // FAN_DUTY_CYCLE_PER_1
        rect(155 ,509, 25, 14);
        textFont(font4, 11);
        fill(255, 255, 255);
        text(device_data, 179, 520);
        noFill();
      }
      break;

    case (FC_FAN_MODE_2):                  // FAN_MODE_2 (VCC_2/PWM_2)

      if (int(device_data) == 0) {            // VCC_2
        fill(0, 0, 0);
        rect(124, 529, 69, 14);
        textFont(font3, 12);
        fill(216, 107, 0);
        text("VCC", 189, 540);
        noFill();
      }

      if (int(device_data) == 1) {            // PWM_2
        fill(0, 0, 0);
        rect(124, 529, 69, 14);
        textFont(font3, 12);
        fill(140, 10, 150);
        text("P", 174, 540);
        text("W", 182, 540);
        text("M", 190, 540);
        noFill();
      }
      break;

    case (FC_FAN_RPM_5):                  // FAN_RPM_5

      if ((int(device_data) >= 0) && (int(device_data) <= 5000)) {
        fill(0, 0, 0);
        rect(116, 544, 48, 14);
        textFont(font4, 11);
        if (int(device_data) < 600) {          // WARNING/(ALARM)
          if (int(device_data) < 500) fill(255, 0, 0); 
          else fill(255, 117, 24);
          warning_flag[24] = true;
        } else {              // OK
          fill(255, 255, 255);
          warning_flag[24] = false;
        }
        text(device_data , 162, 555);
        noFill();
      }
      break;

    case (FC_FAN_RPM_6):                  // FAN_RPM_6

      if ((int(device_data) >= 0) && (int(device_data) <= 5000)) {
        fill(0, 0, 0);
        rect(116, 559, 48, 14);
        textFont(font4, 11);
        if (int(device_data) < 600) {          // WARNING/(ALARM)
          if (int(device_data) < 500) fill(255, 0, 0); 
          else fill(255, 117, 24);
          warning_flag[25] = true;
        } else {              // OK
          fill(255, 255, 255);
          warning_flag[25] = false;
        }
        text(device_data , 162, 570);
        noFill();
      }
      break;


    case (FC_DUTY_CYCLE_PER_2):                // FAN_DUTY_CYCLE_2

      if ((int(device_data) >= 0) && (int(device_data) <= 100)) {

        fill(35, 74, 104);            // FAN_DUTY_CYCLE_BAR_2 
        rect (138, 577, 54, 8);
        fan_duty_bar_2 = map(float(device_data), 0, 100, 0, 54);
        fill(55, 129, 186);
        rect(138, 577, fan_duty_bar_2, 8);

        fill(0, 0, 0);              // FAN_DUTY_CYCLE_PER_2
        rect(155 ,589, 25, 14);
        textFont(font4, 11);
        fill(255, 255, 255);
        text(device_data, 179, 600);
        noFill();
      }
      break;

    case (FC_TEMP_AN3):                  // TEMP_AN3

      if ((float(device_data) >= 0) && (float(device_data) <= 150.0)) {
        fill(0, 0, 0);
        rect(128, 629, 44, 14);
        textFont(font4, 11);
        if ((float(device_data) < 15.0) || (float(device_data) > 50.0)) {  // WARNING/(ALARM)
          if ((float(device_data) < 5.0) || (float(device_data) > 55.0)) fill(255, 0, 0);
          else fill(255, 117, 24);
          warning_flag[26] = true;
        } else {              // OK
          fill(255, 255, 255);
          warning_flag[26] = false;
        }
        text(device_data, 169, 640);
        noFill();
      }
      break;

    case (FC_TEMP_AN4):                  // TEMP_AN4

      if ((float(device_data) >= 0) && (float(device_data) <= 150.0)) {
        fill(0, 0, 0);
        rect(128, 644, 44, 14);
        textFont(font4, 11);
        if ((float(device_data) < 15.0) || (float(device_data) > 50.0)) {  // WARNING/(ALARM)
          if ((float(device_data) < 5.0) || (float(device_data) > 55.0)) fill(255, 0, 0);
          else fill(255, 117, 24);
          warning_flag[27] = true;
        } else {              // OK
          fill(255, 255, 255);
          warning_flag[27] = false;
        }
        text(device_data, 169, 655);
        noFill();
      }
      break;

    case (FC_TEMP_DGF):                  // TEMP_DGF (TOP)

      if ((float(device_data) >= 0) && (float(device_data) <= 150.0)) {
        fill(0, 0, 0);
        rect(128, 659, 44, 14);
        textFont(font4, 11);
        if ((float(device_data) < 10.0) || (float(device_data) > 50.0)) {  // WARNING/(ALARM)
          if ((float(device_data) < 5.0) || (float(device_data) > 55.0)) fill(255, 0, 0);
          else fill(255, 117, 24);
          warning_flag[28] = true;
        } else {              // OK
          fill(255, 255, 255);
          warning_flag[28] = false;
        }
        text(device_data, 169, 670);
        noFill();
      }
      break;

    case (FC_TEMP_ICF):                  // TEMP_ICF (TOP)

      if ((float(device_data) >= 0) && (float(device_data) <= 150.0)) {
        fill(0, 0, 0);
        rect(128, 674, 44, 14);
        textFont(font4, 11);
        if ((float(device_data) < 10.0) || (float(device_data) > 40.0)) {  // WARNING/(ALARM)
          if ((float(device_data) < 5.0) || (float(device_data) > 50.0)) fill(255, 0, 0);
          else fill(255, 117, 24);
          warning_flag[29] = true;
        } else {              // OK
          fill(255, 255, 255);
          warning_flag[29] = false;
        }
        text(device_data, 169, 685);
        noFill();
      }
      break;

          case (FC_FREQ_VCC_1):                  // FAN_FREQ_VCC_1

      if ((float(device_data) >= 0.000) && (float(device_data) <= 60.000)) {
        fill(0, 0, 0);
        rect(120, 694, 48, 14);
        textFont(font4, 11);
        if ((float(device_data) < 24.700) || (float(device_data) > 25.700)) {  // WARNING/(ALARM)
          if ((float(device_data) < 24.500) || (float(device_data) > 25.900)) fill(255, 0, 0);
          else fill(255, 117, 24);
          warning_flag[30] = true;
        } else {              // OK
          fill(255, 255, 255);
          warning_flag[30] = false;
        }
        text(device_data, 164, 705);
        noFill();
      }  
      break;

          case (FC_FREQ_PWM_1):                  // FAN_FREQ_PWM_1

      if ((float(device_data) >= 0.000) && (float(device_data) <= 60.000)) {
        fill(0, 0, 0);
        rect(120, 709, 48, 14);
        textFont(font4, 11);
        if ((float(device_data) < 24.700) || (float(device_data) > 25.700)) {  // WARNING/(ALARM)
          if ((float(device_data) < 24.500) || (float(device_data) > 25.900)) fill(255, 0, 0);
          else fill(255, 117, 24);
          warning_flag[31] = true;
        } else {              // OK
          fill(255, 255, 255);
          warning_flag[31] = false;
        }
        text(device_data, 164, 720);
        noFill();
      }  
      break;

           case (FC_FREQ_VCC_2):                  // FAN_FREQ_VCC_2

      if ((float(device_data) >= 0.000) && (float(device_data) <= 60.000)) {
        fill(0, 0, 0);
        rect(120, 724, 48, 14);
        textFont(font4, 11);
        if ((float(device_data) < 24.700) || (float(device_data) > 25.700)) {  // WARNING/(ALARM)
          if ((float(device_data) < 24.500) || (float(device_data) > 25.900)) fill(255, 0, 0);
          else fill(255, 117, 24);
          warning_flag[32] = true;
        } else {              // OK
          fill(255, 255, 255);
          warning_flag[32] = false;
        }
        text(device_data, 164, 735);
        noFill();
      }  
      break;

          case (FC_FREQ_PWM_2):                  // FAN_FREQ_PWM_2

      if ((float(device_data) >= 0.000) && (float(device_data) <= 60.000)) {
        fill(0, 0, 0);
        rect(120, 739, 48, 14);
        textFont(font4, 11);
        if ((float(device_data) < 24.700) || (float(device_data) > 25.700)) {  // WARNING/(ALARM)
          if ((float(device_data) < 24.500) || (float(device_data) > 25.900)) fill(255, 0, 0);
          else fill(255, 117, 24);
          warning_flag[33] = true;
        } else {              // OK
          fill(255, 255, 255);
          warning_flag[33] = false;
        }
        text(device_data, 164, 750);
        noFill();
      }  
      break;

    case (FC_RAM_ICF):                  // RAM_ICF

      if ((int(device_data) >= 0) && (int(device_data) <= 5000)) {
        fill(0, 0, 0);
        rect(125, 789, 48, 14);
        textFont(font4, 11);  
        if (int(device_data) < 1000) {          // WARNING/(ALARM)
          if (int(device_data) < 800) fill(255, 0, 0);
          else fill(255, 117, 24);
          warning_flag[34] = true;
        } else {              // OK
          fill(255, 255, 255);
          warning_flag[34] = false;
        }
        text(device_data, 171, 800);
        noFill();
      }
      break;


    case (FC_TEMP_OW_3):                  // TEMP_OW_3

      if (sensor_mode_on) {

        if ((float(device_data) >= 0) && (float(device_data) <= 150.0)) {
          sensor_applet.fill(0, 0, 0);
          sensor_applet.rect(130, 69, 42, 14);
          sensor_applet.textFont(font4, 11);
          if ((float(device_data) < 15.0) || (float(device_data) > 50.0)) {  // WARNING/ALARM  
            if ((float(device_data) < 5.0) || (float(device_data) > 55.0)) sensor_applet.fill(255, 0, 0);
            else sensor_applet.fill(255, 117, 24);
            warning_flag[35] = true;
          } else {              // OK
            sensor_applet.fill(255, 255, 255);
            warning_flag[35] = false;
          }
          sensor_applet.text(device_data, 169, 80);
          sensor_applet.noFill();
          sensor_applet.repaint();
        }
      }
      break;


    case (FC_TEMP_OW_4):                  // TEMP_OW_4

      if (sensor_mode_on) {

        if ((float(device_data) >= 0) && (float(device_data) <= 150.0)) {
          sensor_applet.fill(0, 0, 0);
          sensor_applet.rect(130, 84, 42, 14);
          sensor_applet.textFont(font4, 11);
          if ((float(device_data) < 15.0) || (float(device_data) > 50.0)) {  // WARNING/ALARM  
            if ((float(device_data) < 5.0) || (float(device_data) > 55.0)) sensor_applet.fill(255, 0, 0);
            else sensor_applet.fill(255, 117, 24);
            warning_flag[36] = true;
          } else {              // OK
            sensor_applet.fill(255, 255, 255);
            warning_flag[36] = false;
          }
          sensor_applet.text(device_data, 169, 95);
          sensor_applet.noFill();
          sensor_applet.repaint();
        }
      }
      break;

    case (FC_TEMP_I2C_3):                  // TEMP_I2C_3

      if (sensor_mode_on) {

        if ((float(device_data) >= 0) && (float(device_data) <= 150.0)) {
          sensor_applet.fill(0, 0, 0);
          sensor_applet.rect(130, 129, 42, 14);
          sensor_applet.textFont(font4, 11);
          if ((float(device_data) < 15.0) || (float(device_data) > 50.0)) {  // WARNING/ALARM  
            if ((float(device_data) < 5.0) || (float(device_data) > 55.0)) sensor_applet.fill(255, 0, 0);
            else sensor_applet.fill(255, 117, 24);
            warning_flag[37] = true;
          } else {              // OK
            sensor_applet.fill(255, 255, 255);
            warning_flag[37] = false;
          }
          sensor_applet.text(device_data, 169, 140);
          sensor_applet.noFill();
          sensor_applet.repaint();
        }
      }
      break;

    case (FC_TEMP_I2C_4):                  // TEMP_I2C_4

      if (sensor_mode_on) {

        if ((float(device_data) >= 0) && (float(device_data) <= 150.0)) {
          sensor_applet.fill(0, 0, 0);
          sensor_applet.rect(130, 144, 42, 14);
          textFont(font4, 11);
          if ((float(device_data) < 15.0) || (float(device_data) > 50.0)) {  // WARNING/ALARM  
            if ((float(device_data) < 5.0) || (float(device_data) > 55.0)) sensor_applet.fill(255, 0, 0);
            else sensor_applet.fill(255, 117, 24);
            warning_flag[38] = true;
          } else {              // OK
            sensor_applet.fill(255, 255, 255);
            warning_flag[38] = false;
          }
          sensor_applet.text(device_data, 169, 155);
          sensor_applet.noFill();
          sensor_applet.repaint();
        }
      }
      break;
  }
  if ((device_type >= 1000) && (device_type <= 1999)) {          // GOT_PUMP_DATA
      no_pump_data = false;
      pump_data_monitor = 0;
      fan_data_monitor += 1;

  }

  if ((device_type >= 2000) && (device_type <= 2999)) {          // GOT_FAN_DATA
      no_fan_data = false;
      pump_data_monitor += 1;
      fan_data_monitor = 0;
  }

  for (byte i=0; i < NUM_WARNING_FLAGS; i++) {

    if (warning_flag[i]) system_warning = true;
  }

  if (no_data_yet) no_data_yet = false;
  device_type = 0;
  device_CRC = 0;
  device_data = "0";
}


void draw_Pump_Port() {                    // DRAW_PUMP_DATA

  fill(0, 0, 0);
  rect(150, 304, 44, 14);    // ICP_COM_PORT
  rect(128, 319, 46, 14);    // ICP_BAUD_RATE

  textAlign(RIGHT);
  if ((TDPC_connected) || (!no_pump_data)) fill(255, 255, 255);
  else fill(150, 150, 150);
  textFont(font2, 12);
  text(pump_com_port, 192, 315);  // ICP_COM_PORT

  textFont(font4, 11);
  text(pump_baud_rate, 172, 330);  // ICP_BAUD_RATE
  noFill();
}


void draw_Fan_Port() {                    // DRAW_FAN_DATA

  fill(0, 0, 0);
  rect(150, 759, 44, 14);    // ICF_COM_PORT
  rect(128, 774, 46, 14);    // ICF_BAUD_RATE

  textAlign(RIGHT);
  if ((TDFC_connected) || (!no_fan_data)) fill(255, 255, 255);
  else fill(150, 150, 150);
  textFont(font2, 12);
  text(fan_com_port, 192, 770);  // ICF_COM_PORT

  textFont(font4, 11);
  text(fan_baud_rate, 172, 785);   // ICF_BAUD_RATE
  noFill();
}


void pump_No_Data() {                    // NO_PUMP_DATA

  pump_data_monitor = 0;
  no_pump_data = true;
  pump_com_port = "NC";
  pump_baud_rate = 0;
  draw_Pump_Port();
  if (TDPC_connected) {
    TDPC_connected = false;
    portOne.stop();
  }
  if (COM5_present) {
    COM5_present = false;
    print_Debug("Pump Controller disconnected - Serial COM5 stopped");
  }

  if (COM9_present) {
    COM9_present = false;
    print_Debug("Pump Controller disconnected - Serial COM9 stopped");
  }

  fill(0, 0, 0);
   rect(124, 59, 69, 14);    // PUMP_CONTROL (MAN/AUTO/OVD)

  rect(125, 74, 50, 14);    // VCC_PUMP
  rect(125, 89, 50, 14);    // VCC_ICP

  rect(124, 109, 69, 14);    // PUMP_MODE (VCC/PWM)

  rect(116, 124, 48, 14);    // PUMP_RPM_1
  rect(116, 139, 48, 14);    // PUMP_RPM_2
  rect(118 ,154, 48, 14);    // PUMP_FLOW

  rect(155 ,184, 25, 14);    // PUMP_DUTY_CYCLE_PER

  rect(116, 609, 48, 14);    // PSU_RPM

  rect(128, 204, 44, 14);    // TEMP_AN1
  rect(128, 219, 44, 14);    // TEMP_AN2
  rect(128, 234, 44, 14);    // TEMP_DGP
  rect(128, 249, 44, 14);    // TEMP_ICP

  rect(120, 269, 48, 14);    // PUMP_FREQ_VCC
  rect(120, 284, 48, 14);    // PUMP_FREQ_PWM

  rect(125, 334, 48, 14);    // RAM_ICP

  textAlign(RIGHT);
  fill(150, 150, 150);
  textFont(font2, 12);
  text("-", 189, 70);    // PUMP_CONTROL (MAN/AUTO/OVD)

  textFont(font4, 11);
  text("0.000", 174, 85);    // VCC_PUMP
  text("0.000", 174, 100);  // VCC_ICP

  textFont(font2, 12);
  text("-", 189, 120);    // PUMP_MODE (VCC/PWM)

  textFont(font4, 11); 
  text("0", 162, 135);    // PUMP_RPM_1
  text("0", 162, 150);    // PUMP_RPM_2
  text("0.00", 162, 165);    // PUMP_FLOW

  text("0", 179, 195);    // PUMP_DUTY_CYCLE_PER

  text("0", 162, 620);      // PSU_RPM

  text("0.0", 169, 215);    // TEMP_AN1
  text("0.0", 169, 230);    // TEMP_AN2
  text("0.0", 169, 245);    // TEMP_DGP
  text("0.0", 169, 260);    // TEMP_ICP

  text("0.000", 164, 280);  // PUMP_FREQ_VCC
  text("0.000", 164, 295);  // PUMP_FREQ_PWM

  text("0", 172, 345);    // RAM_ICP

  fill(35, 74, 104);
  rect (138, 172, 54, 8);    // PUMP_DUTY_CYCLE_BAR
  noFill();

  if (sensor_mode_on) {

    sensor_applet.fill(0, 0, 0);
    sensor_applet.rect(130, 39, 42, 14);
    sensor_applet.rect(130, 54, 42, 14);
    sensor_applet.rect(130, 99, 42, 14);
    sensor_applet.rect(130, 114, 42, 14);
    sensor_applet.textFont(font4, 11);
    sensor_applet.textAlign(RIGHT);
    sensor_applet.fill(150, 150, 150);
    sensor_applet.text("0.0", 169, 50);
    sensor_applet.text("0.0", 169, 65);
    sensor_applet.text("0.0", 169, 110);
    sensor_applet.text("0.0", 169, 125);
    sensor_applet.noFill();
    sensor_applet.repaint();
  }
}


void fan_No_Data() {                    // NO_FAN_DATA

  fan_data_monitor = 0;
  no_fan_data = true;
  fan_com_port = "NC";
  fan_baud_rate = 0;
  draw_Fan_Port();
  if (TDFC_connected) {
    TDFC_connected = false;
    portTwo.stop();
  }
  if (COM6_present) {
    COM6_present = false;
    print_Debug("Fan Controller disconnected - Serial COM6 stopped");
  }

  fill(0, 0, 0);
  rect(124, 354, 69, 14);    // FAN_CONTROL (MAN/AUTO/OVD)

  rect(125, 369, 50, 14);    // VCC_FAN_1
  rect(125, 384, 50, 14);    // VCC_FAN_2
  rect(125, 399, 50, 14);    // VCC_ICF (BOTTOM)

  rect(124, 419, 69, 14);    // FAN_MODE_1 (VCC_1/PWM_1)

  rect(116, 434, 48, 14);    // FAN_RPM_1
  rect(116, 449, 48, 14);    // FAN_RPM_2
  rect(116, 464, 48, 14);    // FAN_RPM_3
  rect(116, 479, 48, 14);    // FAN_RPM_4

  rect(155 ,509, 25, 14);    // FAN_DUTY_CYCLE_PER_1

  rect(124, 529, 69, 14);    // FAN_MODE_2 (VCC_2/PWM_2)

  rect(116, 544, 48, 14);    // FAN_RPM_5
  rect(116, 559, 48, 14);    // FAN_RPM_6
  
  rect(155 ,589, 25, 14);    // FAN_DUTY_CYCLE_PER_2

  rect(128, 629, 44, 14);    // TEMP_AN3
  rect(128, 644, 44, 14);    // TEMP_AN4
  rect(128, 659, 44, 14);    // TEMP_DGF
  rect(128, 674, 44, 14);    // TEMP_ICF (TOP)

  rect(120, 694, 48, 14);    // FAN_FREQ_VCC_1
  rect(120, 709, 48, 14);    // FAN_FREQ_PWM_1
  rect(120, 724, 48, 14);    // FAN_FREQ_VCC_2
  rect(120, 739, 48, 14);    // FAN_FREQ_PWM_2

  rect(125, 789, 48, 14);    // RAM_ICF

  textAlign(RIGHT);
  fill(150, 150, 150);
  textFont(font2, 12);
  text("-", 189, 365);         // FAN_CONTROL (MAN/AUTO/OVD)

  textFont(font4, 11);
  text("0.000", 174, 380);      // VCC_FAN_1
  text("0.000", 174, 395);      // VCC_FAN_2
  text("0.000", 174, 410);      // VCC_ICF (BOTTOM)

  textFont(font2, 12);
  text("-", 189, 430);         // FAN_MODE_1 (VCC_1/PWM_1)

  textFont(font4, 11); 
  text("0", 162, 445);         // FAN_RPM_1
  text("0", 162, 460);         // FAN_RPM_2
  text("0", 162, 475);         // FAN_RPM_3
  text("0", 162, 490);         // FAN_RPM_4

  text("0", 179, 520);         // FAN_DUTY_CYCLE PER_1

  textFont(font2, 12);
  text("-", 189, 540);         // FAN_MODE_2 (VCC_2/PWM_2)

  textFont(font4, 11); 
  text("0", 162, 555);         // FAN_RPM_5
  text("0", 162, 570);         // FAN_RPM_6

  text("0", 179, 600);         // FAN_DUTY_CYCLE PER_2
 
  text("0.0", 169, 640);       // TEMP_AN3
  text("0.0", 169, 655);       // TEMP_AN4
  text("0.0", 169, 670);       // TEMP_DGP
  text("0.0", 169, 685);       // TEMP_ICP (TOP)
 
  text("0.000", 164, 705);     // FAN_FREQ_VCC_1
  text("0.000", 164, 720);     // FAN_FREQ_PWM_1
  text("0.000", 164, 735);     // FAN_FREQ_VCC_2
  text("0.000", 164, 750);     // FAN_FREQ_PWM_2
  
  text("0", 172, 800);         // RAM_ICF (BOTTOM)  

  fill(35, 74, 104);
  rect (138, 497, 54, 8);    // FAN_DUTY_CYCLE_BAR_1
  rect (138, 577, 54, 8);    // FAN_DUTY_CYCLE_BAR_2
  noFill();

  if (sensor_mode_on) {

    sensor_applet.fill(0, 0, 0);
    sensor_applet.rect(130, 69, 42, 14);
    sensor_applet.rect(130, 84, 42, 14);
    sensor_applet.rect(130, 129, 42, 14);
    sensor_applet.rect(130, 144, 42, 14);
    sensor_applet.textFont(font4, 11);
    sensor_applet.textAlign(RIGHT);
    sensor_applet.fill(150, 150, 150);
    sensor_applet.text("0.0", 169, 80);
    sensor_applet.text("0.0", 169, 95);
    sensor_applet.text("0.0", 169, 140);
    sensor_applet.text("0.0", 169, 155);
    sensor_applet.noFill();
    sensor_applet.repaint();
  }
}


void add_Window_Listeners() {                  // MAIN_WINDOW_LISTENERS

  frame.addWindowStateListener(new WindowStateListener() {
    public void windowStateChanged(WindowEvent e) {
      if ((frame.getExtendedState()) != frame.NORMAL) frame.setExtendedState(frame.NORMAL);
    }
  });

  frame.addWindowFocusListener(new WindowFocusListener() {
    public void windowLostFocus(WindowEvent e) {
    print_Debug("window lost focus");
    popup.setVisible(false);
    if ((frame.getExtendedState()) != frame.NORMAL) frame.setExtendedState(frame.NORMAL);
      }  

    public void windowGainedFocus(WindowEvent e) {  
      print_Debug("window gained focus");
    }
  });
}


void add_popupMenu() {                    // POPUP_MENU

  ActionListener menuListener = new ActionListener() {

    public void actionPerformed (ActionEvent event) {

      if ((event.getActionCommand()) == "Lock Window Position") {

        popup.setVisible(false);
        lock_position.setEnabled(false);
        unlock_position.setEnabled(true);
        window_lock = true;
        print_Debug("Window position is locked");
      }

      if ((event.getActionCommand()) == "Unlock Window Position") {

        popup.setVisible(false);
        unlock_position.setEnabled(false);
        lock_position.setEnabled(true);
        window_lock = false;
        print_Debug("Window position is unlocked");
      }   

      if ((event.getActionCommand()) == "System Warning On") {

        popup.setVisible(false);
        warning_on.setEnabled(false);
        warning_off.setEnabled(true);
        system_warning_control = true;
        print_Debug("system warning is On");
      }

      if ((event.getActionCommand()) == "System Warning Off") {

        popup.setVisible(false);
        warning_off.setEnabled(false);
        warning_on.setEnabled(true);
        system_warning_control = false;
        print_Debug("system warning is Off");
      }

      if ((event.getActionCommand()) == "Open Sensor Window") {

        popup.setVisible(false);
        sensor_on.setEnabled(false);
        sensor_off.setEnabled(true);
        open_sensor_window = true;
        sensor_mode_on = true;
        print_Debug("sensor window open");
      }

      if ((event.getActionCommand()) == "Close Sensor Window") {

        popup.setVisible(false);
        sensor_off.setEnabled(false);
        sensor_on.setEnabled(true);
        sensor_mode_on = false;
              open_sensor_window = false;
        sensor_frame.sensor_frame_quit();
        print_Debug("sensor window closed");
      }

      if ((event.getActionCommand()) == "Open Debug Window") {

        popup.setVisible(false);
        debug_on.setEnabled(false);
        debug_off.setEnabled(true);
        open_debug_window = true;
        debug_mode_on = true;
        debug_quit = false;
        print_Debug("Debug mode is On");
      }

      if ((event.getActionCommand()) == "Close Debug Window") {

        popup.setVisible(false);
        debug_off.setEnabled(false);
        debug_on.setEnabled(true);
        open_debug_window = false;
        debug_mode_on = false;
        print_Debug("Debug mode is Off");
        debug_quit = true;
        debug_frame.setVisible(false); 
        debug_frame.dispose();
      }

      if ((event.getActionCommand()) == "Single Data Input") {

        popup.setVisible(false);
        single_device.setEnabled(false);
        dual_device.setEnabled(true);
        single_input = true;
              select_Com_Port();  
        print_Debug("single input mode selected");
      }

      if ((event.getActionCommand()) == "Dual Data Input") {

        popup.setVisible(false);
        dual_device.setEnabled(false);
        single_device.setEnabled(true);
        single_input = false;
              select_Com_Port();  
        print_Debug("dual input mode selected");
      }

      if ((event.getActionCommand()) == "Close") {

        print_Debug("application is closing");
        exit();
      }
    }
  };
  

  popup.setBorder(new BevelBorder(BevelBorder.RAISED));
  
  popup.add(lock_position);
  popup.add(unlock_position);
  popup.addSeparator();
  popup.add(warning_on);
  popup.add(warning_off); 
  popup.addSeparator();
  popup.add(sensor_on);
  popup.add(sensor_off); 
  popup.addSeparator();
  popup.add(debug_on);
  popup.add(debug_off); 
  popup.addSeparator();
  popup.add(single_device);
  popup.add(dual_device); 
  popup.addSeparator();
  popup.add(close);

  lock_position.addActionListener(menuListener);
  unlock_position.addActionListener(menuListener);
  warning_on.addActionListener(menuListener);
  warning_off.addActionListener(menuListener);
  sensor_on.addActionListener(menuListener);
  sensor_off.addActionListener(menuListener);
  single_device.addActionListener(menuListener);
  dual_device.addActionListener(menuListener);
  debug_on.addActionListener(menuListener);
  debug_off.addActionListener(menuListener);
  close.addActionListener(menuListener);

  if (!window_lock) {
    lock_position.setEnabled(true);
    unlock_position.setEnabled(false);
  } else {
    lock_position.setEnabled(false);
    unlock_position.setEnabled(true);
  }

  if (!system_warning_control) {
    warning_on.setEnabled(true);
    warning_off.setEnabled(false);
  } else {
    warning_on.setEnabled(false);
    warning_off.setEnabled(true);
  }

  if (!open_sensor_window) {
    sensor_on.setEnabled(true);
    sensor_off.setEnabled(false);
    sensor_mode_on = false;

  } else {
    sensor_on.setEnabled(false);
    sensor_off.setEnabled(true);
    sensor_mode_on = true;
  }

  if (!single_input) {
    dual_device.setEnabled(true);
    single_device.setEnabled(false);
  } else {
    single_device.setEnabled(false);
    dual_device.setEnabled(true);
  }

  if (!open_debug_window) {
    debug_on.setEnabled(true);
    debug_off.setEnabled(false);
    debug_mode_on = false;

  } else {
    debug_on.setEnabled(false);
    debug_off.setEnabled(true);
    debug_mode_on = true;
  }

}


public class Console extends WindowAdapter implements WindowListener, ActionListener, Runnable {    // DEBUG_WINDOW

  private JTextArea textArea;
  private Thread reader;
  private Thread reader2;
//  private boolean quit;

  private final PipedInputStream pin=new PipedInputStream(); 
  private final PipedInputStream pin2=new PipedInputStream(); 

  JButton clear_button=new JButton("Clear");
  JButton scroll_button=new JButton();

  public Console() {

    Dimension screenSize=Toolkit.getDefaultToolkit().getScreenSize();
    Dimension frameSize=new Dimension((int)(screenSize.width/2), (int)(screenSize.height/2));

    int x=(int)(frameSize.width/2);
    int y=(int)(frameSize.height/2);


    debug_frame.setLocation(screenSize.width/2-debug_frame.getSize().width/2, screenSize.height/2-debug_frame.getSize().height/2);

    debug_frame.pack();
    debug_frame.setLocationRelativeTo(null);

    debug_frame.setBounds(x, y, frameSize.width, frameSize.height);


    debug_frame.setIconImage(taskbar_image.getImage());

    debug_frame.removeNotify();
    debug_frame.setType(Window.Type.UTILITY);
    debug_frame.setResizable(true);
//    debug_frame.setAlwaysOnTop(true);
    debug_frame.addNotify(); 

    textArea=new JTextArea();
    textArea.setEditable(false);

    clear_button.setFocusPainted(false);
    scroll_button.setFocusPainted(false);

    debug_frame.getContentPane().setLayout(new BorderLayout());
    debug_frame.getContentPane().add(new JScrollPane(textArea), BorderLayout.CENTER);
    debug_frame.getContentPane().add(clear_button, BorderLayout.NORTH);  
    debug_frame.getContentPane().add(scroll_button, BorderLayout.SOUTH);

    debug_frame.setVisible(true);    

    debug_frame.addWindowListener(this);    
    clear_button.addActionListener(this);

    ActionListener scrollListener = new ActionListener() {

      public void actionPerformed(ActionEvent event) {

        if (scroll_on) scroll_on = false;
        else scroll_on = true;
      }
    };

    scroll_button.addActionListener(scrollListener);


    try {
      PipedOutputStream pout=new PipedOutputStream(this.pin);
      System.setOut(new PrintStream(pout, true));

    } catch (java.io.IOException io) {
  
      textArea.append("Couldn't redirect STDOUT to this console\n"+io.getMessage());

    } catch (SecurityException se) {

      textArea.append("Couldn't redirect STDOUT to this console\n"+se.getMessage());
    } 


    try {
      PipedOutputStream pout2=new PipedOutputStream(this.pin2);
      System.setErr(new PrintStream(pout2, true));

    } catch (java.io.IOException io) {

      textArea.append("Couldn't redirect STDERR to this console\n"+io.getMessage());

    } catch (SecurityException se) {

      textArea.append("Couldn't redirect STDERR to this console\n"+se.getMessage());
    }     

    debug_quit=false;

    reader=new Thread(this);
    reader.setDaemon(true);  
    reader.start();  

    reader2=new Thread(this);  
    reader2.setDaemon(true);  
    reader2.start();
  }

  public synchronized void windowClosed(WindowEvent evt) {

    debug_quit=true;

     open_debug_window = false;
    debug_on.setEnabled(true);
    debug_off.setEnabled(false);
    debug_mode_on = false;  

    this.notifyAll();
    try { 
      reader.join(1000);
      pin.close();
    } catch (Exception e) {
    }    
    try { 
      reader2.join(1000);
      pin2.close();
    } catch (Exception e) {
    }
  }

  public synchronized void windowClosing(WindowEvent evt) {

    debug_frame.setVisible(false); 
    debug_frame.dispose();
  }

  public synchronized void actionPerformed(ActionEvent evt) {
    textArea.setText("");
  }

  public synchronized void run() {

    try {      
      while (Thread.currentThread ()==reader) {

         try {
          this.wait(10);
        } catch(InterruptedException ie) {
        }

        if (pin.available()!=0) {
  
          String input=this.readLine(pin);
  
          textArea.append(input);

          if (scroll_on) {
            textArea.setCaretPosition(textArea.getDocument().getLength());
            scroll_button.setText("Auto Scroll On");
            scroll_on = true;

          } else {
  
            textArea.setCaretPosition(textArea.getCaretPosition());
            scroll_button.setText("Auto Scroll Off");
            scroll_on = false;
          }
        }
        if (debug_quit) return;
      }

      while (Thread.currentThread ()==reader2) {

        try { 
          this.wait(10);
  
        } catch(InterruptedException ie) {
        }

        if (pin2.available()!=0) {

          String input=this.readLine(pin2);

          textArea.append(input);

          if (scroll_on) {

            textArea.setCaretPosition(textArea.getDocument().getLength());
            scroll_button.setText("Auto Scroll On");
            scroll_on = true;

          } else {

            textArea.setCaretPosition(textArea.getCaretPosition());
            scroll_button.setText("Auto Scroll Off");
            scroll_on = false;
          }
        }
        if (debug_quit) return;
      }

    } catch (Exception e) {

      textArea.append("\nConsole reports an Internal error.");
      textArea.append("The error is: "+e);
    }
  }

  public synchronized String readLine(PipedInputStream in) throws IOException {
  
    String input="";

    do {

      int available=in.available();
      if (available==0) break;
      byte b[]=new byte[available];
      in.read(b);
      input=input+new String(b, 0, b.length);

    } while ( !input.endsWith ("\n") &&  !input.endsWith("\r\n") && !debug_quit);

    return input;
  }
}


public class PFrame extends JFrame {                  // SENSOR_WINDOW

  public PFrame() {

    sensor_frame = this;
    setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    setContentPane(getContentPane());
    setBounds(0, 0, SENSOR_WINDOW_WIDTH, SENSOR_WINDOW_HEIGHT);
    setLocation(SENSOR_WINDOW_POSITION_X, SENSOR_WINDOW_POSITION_Y);
    setUndecorated(true);
    setTitle("TEARDROP SENSORS");
    setLayout(new BorderLayout());
    setEnabled(true);
    setType(Window.Type.UTILITY);
    setResizable(false);
//    setAlwaysOnTop(true);

    sensor_applet = new secondApplet();
    add(sensor_applet, BorderLayout.CENTER);
    sensor_applet.init();
    show();

    this.addWindowStateListener(new WindowStateListener() {

      public void windowStateChanged(WindowEvent e) {

        print_Debug("sensor window state changed");
      }
    });
  
    this.addWindowListener(new WindowAdapter() {

      public void windowIconified(WindowEvent e) {
        print_Debug("sensor window iconified");
      }
      public void windowDeiconified(WindowEvent e) {
        print_Debug("sensor window deiconified");
      }
      public void windowActivated(WindowEvent e) {
        print_Debug("sensor window activated");
      }
      public void windowDeactivated(WindowEvent e) {
        print_Debug("sensor window deactivated");
      }
      public void windowOpened(WindowEvent e) {
        print_Debug("sensor window opened");
      }
      public void windowClosed(WindowEvent evt) {
        print_Debug("sensor window closed");
      }
      public void windowClosing(WindowEvent evt) {
        print_Debug("sensor window closing");
      }
    });

    sensor_frame.addWindowFocusListener(new WindowFocusListener() {

      public void windowLostFocus(WindowEvent e) {

        print_Debug("sensor window lost focus");

        sensor_popup.setVisible(false);
  
        if ((sensor_frame.getExtendedState()) != frame.NORMAL) sensor_frame.setExtendedState(sensor_frame.NORMAL);
      }  

      public void windowGainedFocus(WindowEvent e) {  

        print_Debug("sensor window gained focus");
      }
    });

    ActionListener sensor_menuListener = new ActionListener() {

      public void actionPerformed (ActionEvent sensor_event) {

        if ((sensor_event.getActionCommand()) == "Lock Window Position") {

          sensor_popup.setVisible(false);
          sensor_lock_position.setEnabled(false);
          sensor_unlock_position.setEnabled(true);
          sensor_window_lock = true;
          print_Debug("sensor window position is locked");
        }

        if ((sensor_event.getActionCommand()) == "Unlock Window Position") {

          sensor_popup.setVisible(false);
          sensor_unlock_position.setEnabled(false);
          sensor_lock_position.setEnabled(true);
          sensor_window_lock = false;
          print_Debug("sensor window position is unlocked");
        }   
  
        if ((sensor_event.getActionCommand()) == "Close") {

          print_Debug("sensor_window is closing");    
          sensor_quit_active = true;
          sensor_frame.sensor_frame_quit();
        }
      }
    };

    sensor_popup.setBorder(new BevelBorder(BevelBorder.RAISED));

    sensor_popup.add(sensor_lock_position);
    sensor_popup.add(sensor_unlock_position);
    sensor_popup.addSeparator();
    sensor_popup.add(sensor_close);

    sensor_lock_position.addActionListener(sensor_menuListener);
    sensor_unlock_position.addActionListener(sensor_menuListener);
    sensor_close.addActionListener(sensor_menuListener);

    if (!sensor_window_lock) {
      sensor_lock_position.setEnabled(true);
      sensor_unlock_position.setEnabled(false);
    } else {
      sensor_lock_position.setEnabled(false);
      sensor_unlock_position.setEnabled(true);
    }
  }


  public void sensor_frame_quit() {

    sensor_mode_on = false;  
    open_sensor_window = false;

    clear_Image_Cache(background_image_2, "background_image_2");
    clear_Image_Cache(button_image, "button_image");
    clear_Image_Cache(button_hover, "button_hover");  

    try {
      sensor_frame.setVisible(false);
      sensor_frame.dispose();
    } catch (Exception e) {

      print_Debug("caught exception on closing sensor frame");
    }
  }
}


public class secondApplet extends PApplet {                // SENSOR_WINDOW_APPLET

  public void setup() {

    smooth();
    size(SENSOR_WINDOW_WIDTH, SENSOR_WINDOW_HEIGHT);
    background(background_image_2);
    image(button_image, 178, 13);
    textFont(font1, 14);
    textAlign(LEFT);
    fill(255, 255, 255);
    text("TEARDROP", 20, 28);
    textFont(font2, 12);
    text("OW TEMP #1", 20, 50); 
    text("OW TEMP #2", 20, 65); 
    text("OW TEMP #3", 20, 80);
    text("OW TEMP #4", 20, 95); 
    text("I2C TEMP #1", 20, 110); 
    text("I2C TEMP #2", 20, 125); 
    text("I2C TEMP #3", 20, 140);
    text("I2C TEMP #4", 20, 155);
    textAlign(RIGHT); 
    text("°C", 190, 50);  
    text("°C", 190, 65);  
    text("°C", 190, 80); 
    text("°C", 190, 95); 
    text("°C", 190, 110);  
    text("°C", 190, 125);  
    text("°C", 190, 140);  
    text("°C", 190, 155);
    textFont(font4, 11); 
    text("0.0", 169, 50);    
    text("0.0", 169, 65);    
    text("0.0", 169, 80);    
    text("0.0", 169, 95);    
    text("0.0", 169, 110);    
    text("0.0", 169, 125);    
    text("0.0", 169, 140);    
    text("0.0", 169, 155);
    noFill();
    noLoop();
  }


  public void draw() {
  }


  void keyPressed() {

    if (key == ESC) key = 0;
  }


  void mouseMoved() {

    if (mouseX >= 178 && mouseX <=192 && mouseY >= 13 && mouseY <= 32) {
      image(button_hover, 178, 13);
      sensor_button_hover_remove = true;
      repaint();

    } else {
      if (sensor_button_hover_remove) {
        sensor_button_hover_remove = false;
        image(button_image, 178, 13);
        repaint();
      }
    }
  }  


  void mousePressed() {

    if (mouseX >= 178 && mouseX <=192 && mouseY >= 13 && mouseY <= 32) {

      if (mouseButton == LEFT) {

        print_Debug("sensor window closed");
        sensor_quit_active = true;
        sensor_frame.sensor_frame_quit();
      }

      if (mouseButton == RIGHT) {

        print_Debug("sensor window moved to original position");

        sensor_frame.setLocation(SENSOR_WINDOW_POSITION_X, SENSOR_WINDOW_POSITION_Y);

        image(button_image, 178, 13);

        repaint();
      }

    } else if (mouseX >= 14 && mouseX <= 90 && mouseY >= 14 && mouseY <= 26) {


      if (mouseButton == LEFT) sensor_popup.setVisible(false);

      if (mouseButton == RIGHT) {

        sensor_popup.setLocation(sensor_frame.getX() + mouseX, sensor_frame.getY() + mouseY);

        sensor_popup.setVisible(true);
      }

    } else {

      sensor_popup.setVisible(false);

      //calculate screen mouse positions before dragging    
      p_global_mouse_x = sensor_frame.getLocation().x + mouseX;
      p_global_mouse_y = sensor_frame.getLocation().y + mouseY;
    }
  }


  void mouseDragged() {

    if ((mouseButton == LEFT) && (sensor_window_lock == false)) {  

      //get x+y position of the frame
      sensor_pos_x = sensor_frame.getLocation().x;
      sensor_pos_y = sensor_frame.getLocation().y;

      //calculate screen mouse positions
      global_mouse_x = (sensor_pos_x + mouseX);
      global_mouse_y = (sensor_pos_y + mouseY);

      //screen x+y movement of mouse
      sensor_pos_x += (global_mouse_x - p_global_mouse_x);  
      sensor_pos_y += (global_mouse_y - p_global_mouse_y);

      //set new frame possition
      if (CONSTRAIN_FRAME) {

        sensor_pos_x = constrain(sensor_pos_x, 0, (displayWidth - SENSOR_WINDOW_WIDTH));    // CONSTRAIN_SENSOR_FRAME_X
        sensor_pos_y = constrain(sensor_pos_y, 0, (displayHeight - (SENSOR_WINDOW_HEIGHT + 30)));    // CONSTRAIN_SENSOR_FRAME_Y
      }

      sensor_frame.setLocation(sensor_pos_x, sensor_pos_y); 

      // remember the last global position
      p_global_mouse_x = global_mouse_x;  
      p_global_mouse_y = global_mouse_y;
    }
  }
}

