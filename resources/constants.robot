*** Variables ***
${URL}    http://%{system}/systemmanager
${SGMAIL_URL}    https://sgmail.logigear.com
${DOWNLOAD_URL}    chrome://Downloads
${USERNAME}    admin
${PASSWORD}    Admin1
${EMAIL_NAME}    tung.vo@logigear.com
${EMAIL_SERVER}    smtp3.logigear.com
${EMAIL_PASSWORD}    cristiano712$

###Character###
${LEFTBRACE}    {{
${RIGHTBRACE}    }}

####-Timing-####
${OBJECT_WAIT}    30
${OBJECT_SHORT_WAIT}    15
${OBJECT_VERY_SHORT_WAIT}    5

###-Folder Setting-###
${DOWNLOAD_DIR}    ${CURDIR}${/}..${/}data\\
${DRIVERS_DIR}    ${CURDIR}${/}..${/}drivers\\
${DIR_PRECONDITION_SNMP}    C:\\Pre Condition\\SNMP
${TEST_DATA_PATH}    C:\\Program Files\\CommScope\\imVision System Manager\\Services\\SNMPServices\\TestData
${DIR_FILE_BK}    C:\\Pre Condition\\BackupData
${DIR_BACKUPFILE_COMMSCOPE} =    C:\Program Files\CommScope\imVision System Manager\Web\Data\BackupFiles
${DIR_PRECONDITION_PICTURE}    C:\\Pre Condition\\Pictures
${DIR_RACKVIEWIMG_COMMSCOPE}    C:\\Program Files\\CommScope\\imVision System Manager\\Web\\Data\\RackViewImages
${DIR_NAVICONS_COMMSCOPE}    C:\\Program Files\\CommScope\\imVision System Manager\\Web\\Images\\NavIcons
${VERTICAL_TRACE_VIEW}    Vertical
${Quareo Discovery Folder}    Quareo Discovery Folder

### Port status ###
${Available}    Available
${Available - Pending}    Available - Pending
${In Use}    In Use
${In Use - Pending}    In Use - Pending
${In Use - 1/3}    In Use - 1/3
${In Use - 1/4}    In Use - 1/4
${In Use - 1/6}    In Use - 1/6
${Name}    Name
${Port Status}    Port Status
${Panel Port Status}    Panel Port Status
${Current Service}    Current Service
${Config}    Config
${VLAN}    VLAN
${Copper}    Copper

### Port id ###
${1}    1
${2}    2
${3}    3
${4}    4
${5}    5
${6}    6

### Menu Items ###
${SITE_NODE}    Site
${Site Manager}    Site Manager
${Administration}    Administration
${Tools}    Tools
${Reports}    Reports
${Spaces}    Spaces
${Layer Image Files}    Layer Image Files
${Move Services}    Move Services
${Devices}    Devices
${Decommission Server}    Decommission Server
${IP}    IP
${MAC}    MAC
${RJ-45}    RJ-45
${LC}    LC
${MPO12}    MPO12
${MPO24}    MPO24
${MPO}    MPO
${SC Duplex}    SC Duplex
${Network Equipment Card}    Network Equipment Card
${Mpo12_Mpo12}    Mpo12_Mpo12
${Mpo24_Mpo24}    Mpo24_Mpo24
${Mpo12_4xLC}    Mpo12_4xLC
${Mpo24_12xLC}    Mpo24_12xLC
${Mpo12_2xMpo12}    Mpo12_2xMpo12
${Fiber}    Fiber
${First Path}    First Path
${Second Path}    Second Path
${Mpo24_3xMpo12}     Mpo24_3xMpo12
${Mpo12_6xLC}    Mpo12_6xLC
${Mpo24_12xLC_EB}    Mpo24_12xLC_EB
${Q2000}    Q2000
${Q4000}    Q4000
${Q4000 1U Chassis}    Q4000 1U Chassis
${QHDEP}    QHDEP
${QNG4}    QNG4
${F12LCDuplex-R12LCDuplex}    F12LCDuplex-R12LCDuplex
${F24LCSimplex-R24LCSimplex}    F24LCSimplex-R24LCSimplex
${Computer}    Computer
${Fax}    Fax
${Phone}    Phone
${Printer}    Printer
${Networked Device}    Networked Device
${Access Point}    Access Point
${MPO1-01}    MPO1-01
${MPO1-02}    MPO1-02
${MPO1-03}    MPO1-03
${MPO1-04}    MPO1-04
${MPO2-01}    MPO2-01
${MPO2-02}    MPO2-02
${MPO2-03}    MPO2-03
${MPO2-04}    MPO2-04
${MPO2}    MPO2
${360 G2 Fiber Shelf (1U)}    360 G2 Fiber Shelf (1U)
${LC 12 Port}    LC 12 Port
${LC 6 Port}    LC 6 Port
${Mpo12_6xLC_EB}    Mpo12_6xLC_EB
${360 G2 Fiber Shelf (2U)}    360 G2 Fiber Shelf (2U)
${4x10G}    4x10G
${Circuit Trace}    Circuit Trace
${F12LCDuplex-R1MPO24-Flipped}    F12LCDuplex-R1MPO24-Flipped
${F12LCDuplex-R1MPO24-HD}    F12LCDuplex-R1MPO24-HD
${F12LCDuplex-R1MPO24-Straight}    F12LCDuplex-R1MPO24-Straight
${F12LCDuplex-R2MPO12-Flipped}    F12LCDuplex-R2MPO12-Flipped
${F12LCDuplex-R2MPO12-Straight}    F12LCDuplex-R2MPO12-Straight
${F24LCSimplex-R2MPO12}    F24LCSimplex-R2MPO12
${F24LCSimplex_CMOD}    F24LCSimplex_CMOD
${F6MPO08-R2MPO24-Straight}    F6MPO08-R2MPO24-Straight
${F8MPO12-R8MPO12}    F8MPO12-R8MPO12
${F8MPO24-R8MPO24}    F8MPO24-R8MPO24
${HD Fiber Shelf (1U)}    HD Fiber Shelf (1U)
${MPO 2 Port}    MPO (2 Port)
${Network Equipment GBIC Slot}    Network Equipment GBIC Slot
${F16MPO12-R16MPO12}    F16MPO12-R16MPO12
${F24LCDuplex-R24LCDuplex}    F24LCDuplex-R24LCDuplex
${QHDEP Chassis}    QHDEP Chassis
${Task List}    Task List
${Add Patch}    Add Patch
${Remove Patch}    Remove Patch
${DM24}    DM24
${Users}    Users
${Immediate}    Immediate
${High}    High
${Normal}    Normal
${Low}    Low
${On Hold}    On Hold
${Feature Options}    Feature Options
${Multiple Zones}    Multiple Zones

### Reports
${Location}    Location
${Service}    Service
${Connection (1)}    Connection (1)
${Switch}    Switch
${Switch Card}    Switch Card
${Switch GBIC Slot}    Switch GBIC Slot
${Switch Port}    Switch Port
${Connection (2)}    Connection (2)
${Rack Group (1)}    Rack Group (1)
${Zone ID (1)}    Zone ID (1)
${Rack Position (1)}    Rack Position (1)
${Rack (1)}    Rack (1)
${Panel (1)}    Panel (1)
${Panel Port (1)}    Panel Port (1)
${Connection (3)}    Connection (3)
${Room (1)}    Room (1)
${Room (2)}    Room (2)
${Rack Group (2)}    Rack Group (2)
${Zone ID (2)}    Zone ID (2)
${Rack Position (2)}    Rack Position (2)
${Rack (2)}    Rack (2)
${Panel (2)}    Panel (2)
${Panel Port (2)}    Panel Port (2)
${Connection (4)}    Connection (4)
${Server ID}    Server ID
${Server Card}    Server Card
${Server GBIC Slot}    Server GBIC Slot
${Server Port}    Server Port
${Equipment (1)}    Equipment (1)
${Equipment Card (1)}    Equipment Card (1)
${Equipment GBIC Slot (1)}    Equipment GBIC Slot (1)
${Equipment Port (1)}    Equipment Port (1)
${Equipment (2)}    Equipment (2)
${Equipment Card (2)}    Equipment Card (2)
${Equipment GBIC Slot (2)}    Equipment GBIC Slot (2)
${Equipment Port (2)}    Equipment Port (2)
${Room (3)}    Room (3)
${Rack Group (3)}    Rack Group (3)
${Rack Position (3)}    Rack Position (3)
${Zone ID (3)}    Zone ID (3)
${Rack (3)}    Rack (3)
${Panel (3)}    Panel (3)
${Panel Port (3)}    Panel Port (3)
${Faceplate}    Faceplate
${Outlet}    Outlet
${Splice Enclosure (1)}    Splice Enclosure (1)
${Splice Tray (1)}    Splice Tray (1)
${Splice (1)}    Splice (1)
${Splice Enclosure (2)}    Splice Enclosure (2)
${Splice Tray (2)}    Splice Tray (2)
${Splice (2)}    Splice (2)
${Connection (5)}    Connection (5)
${View}    View
${Scheduled}    Scheduled
${Pair 1}    Pair 1
${Pair 2}    Pair 2
${Pair 3}    Pair 3
${Pair 4}    Pair 4
${Pair 5}    Pair 5
${Pair 6}    Pair 6
${Pair 7}    Pair 7
${Pair 8}    Pair 8
${Pair 9}    Pair 9
${ Pair 10}    Pair 10
${Pair 11}    Pair 11
${Pair 12}    Pair 12
${A1-2}    A1-2
${A3-4}    A3-4
${A5-6}    A5-6
${A7-8}    A7-8
${A9-10}    A9-10
${A11-12}    A11-12
${1-1}    1-1
${2-2}    2-2
${3-3}    3-3
${4-4}    4-4
${5-5}    5-5
${6-6}    6-6
${01}    01
${02}    02
${03}    03
${04}    04
${05}    05
${06}    06
${07}    07
${08}    08
${09}    09
${10}    10
${11}    11
${12}    12
${13}    13
${14}    14
${15}    15
${16}    16
${17}    17
${18}    18
${19}    19
${20}    20
${A1}    A1
${B1}    B1
${B2}    B2
${B3}    B3
${Module 1A}    Module 1A
${DM12}    DM12
${DM08}    DM08
${Pass-Through}   Pass-Through
${Alpha}   Alpha
${Beta}     Beta
${SLASH}    /
${MPO1}    MPO1
${F2B cabled to}    F2B cabled to
${connected to}    connected to
${service provided to}    service provided to
${patched to}    patched to
${cabled to}    cabled to
${Data}    Data
${Voice}    Voice
${In}    In
${Out}    Out
${A}    A
${B}    B
${Port 01}    01
${Port 02}    02
${Port 03}    03
${Port 04}    04
${Port 05}    05
${Port 06}    06
${No Signal}    No Signal
${Event Log Filters}    Event Log Filters
${Event Type}    Event Type
${No Path}    No Path
${Module 1B}    Module 1B
${Module 1C}    Module 1C
${Module 01}    Module 01
${r01}    r01
${Static (Rear)}    Static (Rear)  
${Yes}    Yes
### Quareo port status ###
${Port Status Empty}    Empty
${Port Status Unmanaged}    Unmanaged
${Port Status Managed}    Managed

### Administration ###
${Events}    Events
${Priority Event Settings}    Priority Event Settings
${System Manager}    System Manager
${Email Servers}    Email Servers
${Event Log Details}    Event Log Details
${iPatch Events}    iPatch Events  
${Event Notification Profiles}    Event Notification Profiles

### Event Log ###
${Plug Inserted in Quareo Port}    Plug Inserted in Quareo Port
${Plug Removed from Quareo Port}    Plug Removed from Quareo Port

### Middleware config ###
${MIDDLEWARE_CONFIG_LOCATION}    C:\\Program Files\\CommScope\\imVision System Manager\\Web\\ConfigFiles\\middleware.config
${MIDDLEWARE_ENABLED_KEY_TRUE}    <add key="Enabled" value="True" />
${MIDDLEWARE_ENABLED_KEY_FALSE}    <add key="Enabled" value="False" />

### Trace ###
${TRACE_OBJECT_SERVICE}    Service:
${TRACE_VLAN}    VLAN:
${TRACE_CONFIG}    Config:
${TRACE_OBJECT_IP}    IP:
${TRACE_OBJECT_MAC}    MAC:

### Event menu ###
${Priority Event Log}    Priority Event Log
${Event Log}    Event Log
${Event Log for Object}    Event Log for Object