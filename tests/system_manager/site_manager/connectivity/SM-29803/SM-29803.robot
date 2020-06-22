*** Settings ***
Resource    ../../../../../resources/icons_constants.robot
Resource    ../../../../../resources/constants.robot

Library   ../../../../../py_sources/logigear/setup.py
Library   ../../../../../py_sources/logigear/api/BuildingApi.py    ${USERNAME}    ${PASSWORD}
Library   ../../../../../py_sources/logigear/api/SimulatorApi.py 
Library   ../../../../../py_sources/logigear/page_objects/system_manager/login/LoginPage${PLATFORM}.py  
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/SiteManagerPage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/patching/PatchingPage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/work_orders/create_work_order/CreateWorkOrderPage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/history/circuit_history/CircuitHistoryPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/quareo_simulator/QuareoDevicePage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/quareo_simulator/CableTemplatesPage${PLATFORM}.py        
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/quareo_unmanaged_connections/QuareoUnmanagedConnectionsPage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/synchronization/SynchronizationPage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/events/event_log/EventLogPage${PLATFORM}.py  
Library   ../../../../../py_sources/logigear/page_objects/system_manager/administration/events/AdmOptionalEventSettingsPage${PLATFORM}.py   
Library   ../../../../../py_sources/logigear/page_objects/system_manager/administration/events/AdmPriorityEventSettingsPage${PLATFORM}.py  
Library   ../../../../../py_sources/logigear/page_objects/system_manager/zone_header/ZoneHeaderPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/tools/database_tools/RestoreDatabasePage${PLATFORM}.py     
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/cabling/CablingPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/front_to_back_cabling/FrontToBackCablingPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/snmp/SNMPPage${PLATFORM}.py

Default Tags    Connectivity    
Force Tags    SM-29803

*** Variables ***
${FLOOR_NAME}    Floor 01
${ROOM_NAME}    Room 01
${RACK_NAME}    Rack 001
${POSITION_RACK_NAME}    1:1 Rack 001
${MPO_PANEL_NAME_1}    MPO Panel 01
${LC_PANEL_NAME_1}    LC Panel 01
${LC_PANEL_NAME_2}    LC Panel 02
${DEVICE_01}    Q4000 01
${DEVICE_02}    Q4000 02
${DEVICE_03}    Q4000 03
${4_MPO12_AA-BB}    (4xMPO12-AA/BB)
${Pass-Through}    (Pass-Through)
${Module 01}    Module 01
${INSTA_PANEL_ALPHA}    Insta Panel Alpha
${INSTA_PANEL_BETA}    Insta Panel Beta
${FP_NAME}    Faceplate 01
${CP_NAME}    CP 01 

##### Constant ######
${TEMPLATE}    Template
${F24LCDuplex-R4MPO12-Straight}    F24LCDuplex-R4MPO12-Straight
${F16MPO12-R16MPO12}    F16MPO12-R16MPO12     
${F24LCDuplex-R24LCDuplex}    F24LCDuplex-R24LCDuplex     
${Cabled to a panel port}    Cabled to a panel port
${Cabled to a network equipment port}    Cabled to a network equipment port
${Not Cabled}    Not Cabled
${Cabled to an Outlet}    Cabled to an Outlet
${MPO3}    MPO3

##### Icon Constant ######   
${PortMPOCabledAvailable}    PortMPOCabledAvailable
${Trace iPatch G2 Fiber}    Trace iPatch G2 Fiber
   
*** Test Cases ***
SM-29803-01_Verify that the user cannot cable Quareo port with new MPO12-6xLC assembly
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM29803_01
    ...    AND    Set Test Variable    ${ip_address_01}    29.8.31.1
    ...    AND    Set Test Variable    ${ip_address_02}    29.8.31.2
    ...    AND    Set Test Variable    ${ip_address_03}    29.8.31.3          
    ...    AND    Delete Building    ${building_name}
    ...    AND    Delete Simulator    ${ip_address_01}
    ...    AND    Delete Simulator    ${ip_address_02}
    ...    AND    Delete Simulator    ${ip_address_03}
    ...    AND    Open Simulator Quareo Page          
    
    [Teardown]    Run Keywords    Delete Building    ${building_name}
    ...    AND    Delete Simulator    ${ip_address_01}
    ...    AND    Delete Simulator    ${ip_address_02}
    ...    AND    Delete Simulator    ${ip_address_03}    
    ...    AND    Close Browser
      
    ${building_name}    Set Variable    BD_SM29803_01 
    ${ip_address_01}    Set Variable     29.8.31.1
    ${ip_address_02}    Set Variable     29.8.31.2    
    ${ip_address_03}    Set Variable     29.8.31.3 
    
    # * On Simulator:
    # _Enable middleware config
    # _Add Q4000 device 01 F24LCDuplex-R4MPO12-Straight with un-populate data 
    Add Simulator Quareo Device    ${ip_address_01}    addType=${TEMPLATE}    deviceType=${Q4000}    modules=${F24LCDuplex-R4MPO12-Straight}   
    # _Add Q4000 device 02 F16MPO12-R16MPO12
    Add Simulator Quareo Device    ${ip_address_02}    addType=${TEMPLATE}    deviceType=${Q4000}    modules=${F16MPO12-R16MPO12}  
    # _Add Q4000 device 03 F24LCDuplex-R24LCDuplex
    Add Simulator Quareo Device    ${ip_address_03}    addType=${TEMPLATE}    deviceType=${Q4000}    modules=${F24LCDuplex-R24LCDuplex}
    ${simulator}    Get Current Tab Alias
      
    # 1. Launch and log into SM Web
    Open New Tab    ${URL}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${Quareo Discovery Folder}
    
	# * On SM:
    # 3. Add Quareo device in pre-condition to Rack 001 and sync successfully
    Create Object    buildingName=${building_name}    floorName=${FLOOR_NAME}    roomName=${ROOM_NAME}    rackName=${RACK_NAME}
    Add Quareo    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${Q4000 1U Chassis}    ${DEVICE_01}    ${ip_address_01}
    Add Quareo    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${Q4000 1U Chassis}    ${DEVICE_02}    ${ip_address_02}
    Add Quareo    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${Q4000 1U Chassis}    ${DEVICE_03}    ${ip_address_03}
    
    # 4. Add to Rack 001:
    # _LC Generic Panel 01
    # _MPO Generic Panel 01
    Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${LC_PANEL_NAME_1}    portType=${LC}
    Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${MPO_PANEL_NAME_1}    portType=${MPO}
    
    Synchronize By Context Menu On Site Tree    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DEVICE_01}
    Wait Until Device Synchronize Successfully    ${ip_address_01}
    Close Quareo Synchronize Window
    
    Synchronize By Context Menu On Site Tree    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DEVICE_02}
    Wait Until Device Synchronize Successfully    ${ip_address_02}
    Close Quareo Synchronize Window
    
    Synchronize By Context Menu On Site Tree    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DEVICE_03}
    Wait Until Device Synchronize Successfully    ${ip_address_03}
    Close Quareo Synchronize Window
    
	# 5. Set Static (Rear) for port:
    # _Q4000 01/Module 01/01
    # _Q4000 01/Module 01/03
    # _Q4000 03/Module 01/01
    Edit Port On Content Table    ${SITE_NODE}>${building_name}>${FLOOR_NAME}>${ROOM_NAME}>${POSITION_RACK_NAME}>${DEVICE_01}>${Module 01} ${4_MPO12_AA-BB}     ${01}    staticRear=${True}    delimiterTree=> 
    Edit Port On Content Table    ${SITE_NODE}>${building_name}>${FLOOR_NAME}>${ROOM_NAME}>${POSITION_RACK_NAME}>${DEVICE_01}>${Module 01} ${4_MPO12_AA-BB}     ${03}    staticRear=${True}    delimiterTree=>
    Edit Port On Content Table    ${SITE_NODE}>${building_name}>${FLOOR_NAME}>${ROOM_NAME}>${POSITION_RACK_NAME}>${DEVICE_03}>${Module 01} ${Pass-Through}     ${01}    staticRear=${True}    delimiterTree=>
    
	# 6. Set Static (Front) for port:
    # _Q4000 01/Module 01/02
    # _Q4000 02/Module 01/01
    Edit Port On Content Table    ${SITE_NODE}>${building_name}>${FLOOR_NAME}>${ROOM_NAME}>${POSITION_RACK_NAME}>${DEVICE_01}>${Module 01} ${4_MPO12_AA-BB}     ${02}    staticFront=${True}    delimiterTree=>
    Edit Port On Content Table    ${SITE_NODE}>${building_name}>${FLOOR_NAME}>${ROOM_NAME}>${POSITION_RACK_NAME}>${DEVICE_02}>${Module 01} ${Pass-Through}     ${01}    staticFront=${True}    delimiterTree=>
    
    # 7. Select Q4000 01/Module 01/01 and open Cabling window
    Open Cabling Window    ${SITE_NODE}>${building_name}>${FLOOR_NAME}>${ROOM_NAME}>${POSITION_RACK_NAME}>${DEVICE_01}>${Module 01} ${4_MPO12_AA-BB}     ${01}    delimiter=>
    # 8. Select Panel 01/01 in To pane
    Click Tree Node Cabling    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${LC_PANEL_NAME_1}/${01}
    # 9. Observe new connection assembly
    # _The new connection assembly (MPO12-6xLC) is disabled
    Check Mpo Connection Type State On Cabling Window    mpoConnectionType=${Mpo12_6xLC_EB}    isEnabled=${False}    mpoConnectionTab=${MPO12}
    Close Cabling Window
    
    # 10. Select Q4000 02/Module 01/01 and open F2B Cabling window
    Open Front To Back Cabling Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DEVICE_02}/${Module 01} ${Pass-Through}     ${01}        
    # 11. Select Q4000 03/Module 01/01 in To pane
    Click Tree Node Front To Back Cabling    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DEVICE_03}/${Module 01} ${Pass-Through}/r${01}
    # 12. Observe new connection assembly
    # _The new connection assembly (MPO12-6xLC) is disabled
    Check Mpo Connection Type State On Cabling Window    mpoConnectionType=${Mpo12_6xLC_EB}    isEnabled=${False}    mpoConnectionTab=${MPO12}       
    
    # 13. Select Q4000 01/Module 01/02 and open F2B cabling window
    Click Tree Node Front To Back Cabling    From    ${SITE_NODE}>${building_name}>${FLOOR_NAME}>${ROOM_NAME}>${POSITION_RACK_NAME}>${DEVICE_01}>${Module 01} ${4_MPO12_AA-BB}>${02}    delimiter=>
    # 14. Select Panel 02/01 in To pane
    Click Tree Node Front To Back Cabling    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_PANEL_NAME_1}/${01}
    # 15. Observe new connection assembly
    # _The new connection assembly (6xLC-MPO12) is disabled
    Check Mpo Connection Type State On Cabling Window    mpoConnectionType=${Mpo12_6xLC_EB}    isEnabled=${False}    mpoConnectionTab=${MPO12}  
    Close Front To Back Cabling Window
    
SM-29803-02_Verify that user cannot create cabling MPO12-6xLC ULL Assembly between InstaPatch (Alpha/Beta) Port and Equipment port
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM29803_02
    ...    AND    Delete Building    ${building_name}
    ...    AND    Open Sm Login Page      
    
    [Teardown]    Run Keywords    Delete Building    ${building_name}    
    ...    AND    Close Browser
    
    ${ip_address_01}    Set Variable    10.5.6.97
    ${LC_PANEL_NAME_3}    Set Variable    LC Panel 03
    ${LC_NE_02}    Set Variable    LC NE 02
    ${LC_MNE_01}    Set Variable    LC Managed Switch 01
    ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}       

    Login To SM    ${USERNAME}    ${PASSWORD}
    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${Quareo Discovery Folder}
    # * On SM:
    # 3. Add to Rack 001:
    Create Object    buildingName=${building_name}    floorName=${FLOOR_NAME}    roomName=${ROOM_NAME}    rackName=${RACK_NAME}
    # _InstaPatch Panel 01 (Alpha)
    Add Ipatch Fiber Equipment    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${360 G2 iPatch - 2U}    ${INSTA_PANEL_ALPHA}
    ...    ${Module 1A},True,${LC 12 Port},${Alpha}
    # _InstaPatch Panel 02 (Beta)
    Add Ipatch Fiber Equipment    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${360 G2 iPatch - 2U}    ${INSTA_PANEL_BETA}
    ...    ${Module 1A},True,${LC 12 Port},${Beta}
    # _LC Panel 03
    Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${LC_PANEL_NAME_3}    portType=${LC}
    # _LC Managed Switch 01 and sync it successfully) (e.g. 10.5.6.97)
    Add Managed Switch    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${LC_MNE_01}    ${ip_address_01}    IPv4    ${False}
    
    Synchronize Managed Switch    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${LC_MNE_01}
    Open Synchronize Status Window
    Wait Until Synchronize Successfully    ${LC_MNE_01}    ${ip_address_01}
         
    # _LC NE 02
    Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${LC_NE_02}    
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${LC_NE_02}    name=${01}    portType=${LC}    quantity=6  
    
    # 4. Cabling from Panel 01/Module 1A/MPO 01 to Panel 03/01-06
    Open Cabling Window    ${SITE_NODE}/${building_name}
    Click Tree Node Cabling    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${INSTA_PANEL_ALPHA}/${Module 1A} (${Alpha})/${MPO} ${01}	   
    
    # 5. Observe new connection type
    # _MPO12-6xLC ULL Assembly connection type is disabled
    :FOR    ${i}    IN RANGE    0    len(${port_list})    
    \    Click Tree Node Cabling    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${LC_PANEL_NAME_3}/${port_list}[${i}]
    \    Check Mpo Connection Type State On Cabling Window    mpoConnectionType=${Mpo12_6xLC_EB}    isEnabled=${False}    mpoConnectionTab=${MPO12}
    
    # 6. Cabling from Panel 02/Module 1A/MPO 01 to Switch/Card 01/01-02
    Click Tree Node Cabling    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${INSTA_PANEL_BETA}/${Module 1A} (${Beta})/${MPO} ${01}
    
    # 7. Observe new connection type
    # _MPO12-6xLC ULL Assembly connection type is disabled
    :FOR    ${i}    IN RANGE    0    len(${port_list})    
    \    Click Tree Node Cabling    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${LC_MNE_01}/Card ${01}/${port_list}[${i}]
    \    Check Mpo Connection Type State On Cabling Window    mpoConnectionType=${Mpo12_6xLC_EB}    isEnabled=${False}    mpoConnectionTab=${MPO12}
   
    # 8. Cabling from Panel 01/Module 1A/MPO 01 to NE 02/01
    Click Tree Node Cabling    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${INSTA_PANEL_ALPHA}/${Module 1A} (${Alpha})/${MPO} ${01}

    # 9. Observe new connection type
    # _MPO12-6xLC ULL Assembly connection type is disabled
    :FOR    ${i}    IN RANGE    0    len(${port_list})    
    \    Click Tree Node Cabling    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${LC_NE_02}/${port_list}[${i}]
    \    Check Mpo Connection Type State On Cabling Window    mpoConnectionType=${Mpo12_6xLC_EB}    isEnabled=${False}    mpoConnectionTab=${MPO12}
    Close Cabling Window
    
    # 10. Add to Room 01:
    # _LC Faceplate 01
    # _LC CP 01
    Add Faceplate    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${FP_NAME}    ${LC}
    Add Consolidation Point    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${CP_NAME}    portType=${LC}
    
    # 11. Cabling from Panel 02/Module 1A/MPO 01 to Faceplate 01/01
    Open Cabling Window    ${SITE_NODE}/${building_name}
    Click Tree Node Cabling    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${INSTA_PANEL_BETA}/${Module 1A} (${Beta})/${MPO} ${01}
    Click Tree Node Cabling    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${FP_NAME}/${01}
    # 12. Observe new connection type
    # _MPO12-6xLC ULL Assembly connection type is disabled
    Check Mpo Connection Type State On Cabling Window    mpoConnectionType=${Mpo12_6xLC_EB}    isEnabled=${False}    mpoConnectionTab=${MPO12}
    
    # 13. Cabling from Panel 01/Module 1A/MPO 01 to CP 01/01
    Click Tree Node Cabling    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${INSTA_PANEL_ALPHA}/${Module 1A} (${Alpha})/${MPO} ${01}
    Click Tree Node Cabling    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${CP_NAME}/${01}
    # 14. Observe new connection type 
    # _MPO12-6xLC ULL Assembly connection type is disabled
    Check Mpo Connection Type State On Cabling Window    mpoConnectionType=${Mpo12_6xLC_EB}    isEnabled=${False}    mpoConnectionTab=${MPO12}
    Close Cabling Window
    
SM-29803-03_Verify that user can create/remove cabling MPO12-6xLC ULL Assembly from Generic Panel to Generic Panel/outlet
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM29803_03
    ...    AND    Delete Building    ${building_name}
    ...    AND    Open Sm Login Page       
    
    [Teardown]    Run Keywords    Delete Building    ${building_name}    
    ...    AND    Close Browser
    
    [Tags]    Sanity

    ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}       
    ${object_position_list}    Create List    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}
    ${pair_list}	Create List    ${Pair 1}    ${Pair 2}    ${Pair 3}    ${Pair 4}    ${Pair 5}    ${Pair 6}
    
    Login To SM    ${USERNAME}    ${PASSWORD}
    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${Quareo Discovery Folder}
    Create Object    buildingName=${building_name}    floorName=${FLOOR_NAME}    roomName=${ROOM_NAME}    rackName=${RACK_NAME}
    
    # * On SM:
    # 3. Add to Rack 001:
        # _MPO Generic Panel 01
        # _LC Generic Panel 02   
    Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${MPO_PANEL_NAME_1}    portType=${MPO}
    Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${LC_PANEL_NAME_1}    portType=${LC}
    
    # 4. Add to Room 01:
        # _LC Faceplate 01
    Add Faceplate    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${FP_NAME}    ${LC}
    
    # 5. Cabling from Panel 01/Module 1A/MPO 01 to Panel 02/Module 1A/01-06
    Open Cabling Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_PANEL_NAME_1}
    Create Cabling    Connect    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_PANEL_NAME_1}/${01}    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${LC_PANEL_NAME_1}    ${MPO12}    ${Mpo12_6xLC_EB}    ${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}
    ...    portsTo=${01},${02},${03},${04},${05},${06}
    # _MPO12-6xLC connection type shows with purple background for 6 number
    # _Icons of ports:
      # + Panel 01/Module 1A/MPO 01: cabled icon
          # + Port type is MPO12
    Check Icon Object On Cabling Tree    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_PANEL_NAME_1}/${01}    ${PortMPOPanelCabledAvailable}
      # + Panel 02/01-06: cabled icon
    :FOR    ${i}    IN RANGE    0    len(${port_list})
        \    Check Icon Object On Cabling Tree    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${LC_PANEL_NAME_1}/${port_list}[${i}]    ${PortFDPanelCabledAvailable}
    
    # _Port statuses:
      # + Panel 01/Module 1A/MPO 01: 
        # Port Status: Available
        # Cabled to a panel port.
    Check Port Status On Cabling Window    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_PANEL_NAME_1}/${01}    ${Port Status}: ${Available}
    Check Port Status On Cabling Window    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_PANEL_NAME_1}/${01}    ${Cabled to a panel port}
      # + Panel 02/01-06: 
        # Port Status: Available
        # Cabled to a panel port.
    :FOR    ${i}    IN RANGE    0    len(${port_list})
        \    Check Port Status On Cabling Window    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${LC_PANEL_NAME_1}/${port_list}[${i}]    ${Port Status}: ${Available}
        \    Check Port Status On Cabling Window    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${LC_PANEL_NAME_1}/${port_list}[${i}]    ${Cabled to a panel port}
          
    # _The circuit trace displays in Horizontal:
        # Tab 1-1: Panel 01/12 1 [/A1] -> MPO12-6xLC ULL Assembly cabled to -> Panel 02/1 [/1-1]
        # ...
        # Tab 6-6: Panel 01/12 1 [/A1] -> MPO12-6xLC ULL Assembly cabled to -> Panel 02/6 [/6-6]
    Open Trace Window On Cabling    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_PANEL_NAME_1}/${01}    
    :FOR    ${i}    IN RANGE    0    len(${port_list})
	    \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
	    \    Check Trace Object On Site Manager    indexObject=1    mpoType=12    objectPosition=1 [ /${A1}]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_PANEL_NAME_1}/${01}
        ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${MPO_PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}        connectionType=${TRACE_MPO12_6X_LC_BACK_BACK_EB_CABLING} 
        \    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${object_position_list}[${i}] [ /${pair_list}[${i}]]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${LC_PANEL_NAME_1}/${port_list}[${i}]
        ...    objectType=${TRACE_GENERIC_FIBER_PANEL_IMAGE}    informationDevice=${port_list}[${i}]->${LC_PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window
    
    # 6. Print the circuit and observe
    # 7. Remove cabling from Cabling window between panel 01 and panel 02
    Create Cabling    DisConnect    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_PANEL_NAME_1}/${01}    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${LC_PANEL_NAME_1}    ${MPO12}    ${Mpo12_6xLC_EB}    ${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}
    ...    portsTo=${01},${02},${03},${04},${05},${06}
    
    # 8.  Observe icons of ports, port statuses and trace in cabling window
    # _Icons of ports:
      # + Panel 01/Module 1A/MPO 01: no cabled icon
      Check Icon Object On Cabling Tree    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_PANEL_NAME_1}/${01}    ${PortMPOUncabledAvailable}
      
      # + Panel 02/01-06: no cabled icon
      :FOR    ${i}    IN RANGE    0    len(${port_list})
        \    Check Icon Object On Cabling Tree    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${LC_PANEL_NAME_1}/${port_list}[${i}]    ${PortFDUncabledAvailable}
       
    # _Port statuses:
      # + Panel 01/Module 1A/MPO 01: 
        # Port Status: Available
        # Cable Status: Not Cabled
    Check Port Status On Cabling Window    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_PANEL_NAME_1}/${01}    ${Port Status}: ${Available}
    Check Port Status On Cabling Window    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_PANEL_NAME_1}/${01}    ${Not Cabled} 

      # + Panel 02/ 01-06:
    # Port Status: Available
    # Cable Status: Not Cabled
     :FOR    ${i}    IN RANGE    0    len(${port_list})
        \    Check Port Status On Cabling Window    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${LC_PANEL_NAME_1}/${port_list}[${i}]    ${Port Status}: ${Available}
        \    Check Port Status On Cabling Window    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${LC_PANEL_NAME_1}/${port_list}[${i}]    ${Not Cabled}

    # _The circuit trace displays: 
    # Panel 01/01
    Open Trace Window On Cabling    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_PANEL_NAME_1}/${01}
    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=1     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_PANEL_NAME_1}/${01}
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${MPO_PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window
    
    # Panel 02/01-06
    :FOR    ${i}    IN RANGE    0    len(${port_list})
	    \    Open Trace Window On Cabling    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${LC_PANEL_NAME_1}/${port_list}[${i}] 
        \    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=${object_position_list}[${i}]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${LC_PANEL_NAME_1}/${port_list}[${i}]
        ...    objectType=${TRACE_GENERIC_FIBER_PANEL_IMAGE}    informationDevice=${port_list}[${i}]->${LC_PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
        \    Close Trace Window
    
    # 9. Cabling from Panel 01/Module 1A/MPO 01 to Faceplate 01/01-06
    Create Cabling    Connect    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_PANEL_NAME_1}/${01}    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${FP_NAME}    ${MPO12}    ${Mpo12_6xLC_EB}    ${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}
    ...    portsTo=${01},${02},${03},${04},${05},${06}

    # 10. Observe new connection type, icons of ports, port statuses and trace them in Cabling window
    # _Icons of ports:
      # + Panel 01/Module 1A/MPO 01: cabled icon
    Check Icon Object On Cabling Tree    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_PANEL_NAME_1}/${01}    ${PortMPOCabledAvailable}
      # + Faceplate 01/01-06: cabled icon
    :FOR    ${i}    IN RANGE    0    len(${port_list})
    \    Check Icon Object On Cabling Tree    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${FP_NAME}/${port_list}[${i}]    ${PortFDCabledAvailable}
    
    # _Port statuses:
      # + Panel 01/Module 1A/MPO 01: 
          # Port Port Status: Available
          # Cabled to an Outlet.
    Check Port Status On Cabling Window    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_PANEL_NAME_1}/${01}    ${Port Status}: ${Available}
    Check Port Status On Cabling Window    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_PANEL_NAME_1}/${01}    ${Cabled to an Outlet}
    
      # + Faceplate 01/01-06: 
          # Port Status: Available
          # Cabled to a panel port.
     :FOR    ${i}    IN RANGE    0    len(${port_list})
     \    Check Port Status On Cabling Window    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${FP_NAME}/${port_list}[${i}]    ${Port Status}: ${Available}
     \    Check Port Status On Cabling Window    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${FP_NAME}/${port_list}[${i}]    ${Cabled to a panel port}
        
    # _The circuit trace displays in Horizontal:
    # Tab 1-1: Panel 01/12 1 [/A1] -> MPO12-6xLC ULL Assembly cabled to -> Faceplate 01/1 [/1-1]
    # ...
    # Tab 6-6: Panel 01/12 1 [/A1] -> MPO12-6xLC ULL Assembly cabled to -> Faceplate 01/6 [/6-6]
    Open Trace Window On Cabling    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_PANEL_NAME_1}/${01}
    :FOR    ${i}    IN RANGE    0    len(${port_list})
	    \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
	    \    Check Trace Object On Site Manager    indexObject=1    mpoType=12    objectPosition=1 [ /${A1}]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_PANEL_NAME_1}/${01}
        ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${MPO_PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}        connectionType=${TRACE_MPO12_6X_LC_BACK_BACK_EB_CABLING} 
        \    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${object_position_list}[${i}] [ /${pair_list}[${i}]]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${FP_NAME}/${port_list}[${i}]
        ...    objectType=${TRACE_LC_FACEPLATE_IMAGE}    informationDevice=${port_list}[${i}]->${FP_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window
    
    # 11. Remove cabling by Remove Cabling function from Panel 01 to Faceplate 01
    Close Cabling Window
    Remove Cabling By Context Menu On Site Tree    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_PANEL_NAME_1}
    
    # 12. Observe icons of ports, port statuses and trace in cabling window
    Open Cabling Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_PANEL_NAME_1}
    # _Icons of ports:
      # + Panel 01/Module 1A/MPO 01: no cabled icon
    Check Icon Object On Cabling Tree    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_PANEL_NAME_1}/${01}    ${PortMPOUncabledAvailable}
      # + Faceplate 01/01-06: no cabled icon
    :FOR    ${i}    IN RANGE    0    len(${port_list})
    \    Check Icon Object On Cabling Tree    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${FP_NAME}/${port_list}[${i}]    ${PortFDUncabledAvailable}      

    # _Port statuses:
      # + Panel 01/Module 1A/MPO 01: Port Status: Available
        # Cable Status: Not Cabled
    Check Port Status On Cabling Window    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_PANEL_NAME_1}/${01}    ${Port Status}: ${Available}    
    Check Port Status On Cabling Window    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_PANEL_NAME_1}/${01}    ${Not Cabled}
    
      # + Faceplate 01/ 01-06:
        # Port Status: Available
        # Cable Status: Not Cabled
    :FOR    ${i}    IN RANGE    0    len(${port_list})
     \    Check Port Status On Cabling Window    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${FP_NAME}/${port_list}[${i}]    ${Port Status}: ${Not Cabled}    
     \    Check Port Status On Cabling Window    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${FP_NAME}/${port_list}[${i}]    ${Not Cabled}    
     
    # _The circuit trace displays: 
    # Panel 01/01
    Open Trace Window On Cabling    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_PANEL_NAME_1}/${01}
    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=1     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_PANEL_NAME_1}/${01}
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=${01}->${MPO_PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window
    
    # Faceplate 01/01-06
    :FOR    ${i}    IN RANGE    0    len(${port_list})
	    \    Open Trace Window On Cabling    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${FP_NAME}/${port_list}[${i}] 
        \    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=${object_position_list}[${i}]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${FP_NAME}/${port_list}[${i}]
        ...    objectType=${TRACE_LC_FACEPLATE_IMAGE}    informationDevice=${port_list}[${i}]->${FP_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
        \    Close Trace Window
   
SM-29803-04_Verify that user can create/remove cabling MPO12-6xLC ULL Assembly between DM08 and equipment port
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM29803_04
    ...    AND    Delete Building    ${building_name}
    ...    AND    Open Sm Login Page       
    
    [Teardown]    Run Keywords    Delete Building    ${building_name}    
    ...    AND    Close Browser
    
    ${DM08_Panel_02}    Set Variable    DM08 Panel 02
    ${DM12_Panel_03}    Set Variable    DM12 Panel 03
    ${MPO_Insta_Panel_04}    Set Variable    MPO_Insta_Panel_04
    ${LC_NE_01}    Set Variable    LC NE 01
    ${LC_NE_02}    Set Variable    LC NE 02
    ${Module 1A shortcut}    Set Variable    ..le 1A
    ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}       
    ${object_position_list}    Create List    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}
    ${pair_list}	Create List    ${Pair 1}    ${Pair 2}    ${Pair 3}    ${Pair 4}    ${Pair 5}    ${Pair 6}
    
    Login To SM    ${USERNAME}    ${PASSWORD}
    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${Quareo Discovery Folder}
    Create Object    buildingName=${building_name}    floorName=${FLOOR_NAME}    roomName=${ROOM_NAME}    rackName=${RACK_NAME}
    
    # * On SM:
    # 3. Add to Rack 001:
        # _LC Generic Panel 01
        Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${LC_PANEL_NAME_1}    portType=${LC}
        # _DM08 Panel 02
        Add Systimax Fiber Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${360 G2 Fiber Shelf (1U)}    ${DM08_Panel_02}    Module 1A,${TRUE},LC 12 Port,${DM 08};Module 1B,${FALSE};Module 1C,${FALSE};Module 1D,${FALSE}
        # _DM12 Panel 03
        Add Systimax Fiber Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${360 G2 Fiber Shelf (1U)}    ${DM12_Panel_03}    Module 1A,${TRUE},LC 12 Port,${DM 12};Module 1B,${FALSE};Module 1C,${FALSE};Module 1D,${FALSE}
        # _MPO Instapatch Panel 04
        Add Systimax Fiber Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${360 G2 Fiber Shelf (1U)}    ${MPO_Insta_Panel_04}    Module 1A,${TRUE},MPO (8 Port),${DM 12};Module 1B,${FALSE};Module 1C,${FALSE};Module 1D,${FALSE}
        # _LC NE 01
        Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${LC_NE_01}    
        Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${LC_NE_01}    name=${01}    portType=${LC}    quantity=6  
        
    # 4. Add to Room 01:
        # _LC NE 02
        Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${LC_NE_02}    
        Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${LC_NE_02}    name=${01}    portType=${LC}    quantity=6  
        
        # _CP 01
        Add Consolidation Point    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${CP_NAME}    portType=${LC}        

    # 5. Cabling Panel 02/Module 1A/MPO 01 to NE 02/01-06
        Open Cabling Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DM08_Panel_02}
        Create Cabling    Connect    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DM08_Panel_02}/${Module 1A} (${DM08})/${MPO} ${01}    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${LC_NE_02}    ${MPO12}    ${Mpo12_6xLC_EB}    ${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}
        ...    portsTo=${01},${02},${03},${04},${05},${06}  
 
    # 6. Observe icons of ports, port statuses and trace in Cabling window
    # _Icons of ports:
      # + Panel 02/Module 1A/MPO 01: cabled icon
          # * Port type is MPO12
      Check Icon Object On Cabling Tree    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DM08_Panel_02}/${Module 1A} (${DM08})/${MPO} ${01}    ${PortMPOServiceCabledAvailable}
          
      # + NE 2/01-06: patched icon
      :FOR    ${i}    IN RANGE    0    len(${port_list})
     \    Check Icon Object On Cabling Tree    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${LC_NE_02}/${port_list}[${i}]    ${PortNEFDPanelCabled}
      
      # _Port statuses: NE 02// 01-04:
          # Port Status: Available
          # Cabled to a panel port.
          ${j}    Evaluate    len(${port_list})-2
          
      :FOR    ${i}    IN RANGE    0    ${j} 
     \    Check Port Status On Cabling Window    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${LC_NE_02}/${port_list}[${i}]    ${Port Status}: ${Available}    
     \    Check Port Status On Cabling Window    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${LC_NE_02}/${port_list}[${i}]    ${Cabled to a panel port}
     Close Cabling Window
      
    # _The circuit trace displays: 
        # + MPO1-01: service box -> connected to -> NE 02/01 -> 6xLC-MPO12 cabled to -> Panel 02/Module 1A/7 (MPO1)
        Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DM08_Panel_02}/${Module 1A} (${DM08})    ${MPO}${1}-${01}    
        Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE}
        ...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
        Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${LC_NE_02}/${01}
        ...    objectType=${Trace Switch}     informationDevice=${01}->${LC_NE_02}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_FIBER_FRONT_TO_BACK_CABLING} 
        Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=7 (${MPO1})     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DM08_Panel_02}/${Module 1A} (${DM08})/${MPO}${1}-${01} 
        ...    objectType=${TRACE_DM08}     informationDevice=${MPO}${1}-${01}->${Module 1A} (${DM08})->${DM08_Panel_02}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
        Close Trace Window
        
        # + MPO1-02: service box -> connected to -> NE 02/02 -> 6xLC-MPO12 cabled to -> Panel 02/Module 1A/8 (MPO1)
        Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DM08_Panel_02}/${Module 1A} (${DM08})    ${MPO}${1}-${02}    
        Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE}
        ...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
        Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${LC_NE_02}/${02}
        ...    objectType=${Trace Switch}     informationDevice=${02}->${LC_NE_02}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_FIBER_FRONT_TO_BACK_CABLING} 
        Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=8 (${MPO1})     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DM08_Panel_02}/${Module 1A} (${DM08})/${MPO}${1}-${02} 
        ...    objectType=${TRACE_DM08}     informationDevice=${MPO}${1}-${02}->${Module 1A} (${DM08})->${DM08_Panel_02}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
        Close Trace Window
        
        # + MPO1-03: service box -> connected to -> NE 02/03 -> 6xLC-MPO12 cabled to -> Panel 02/Module 1A/1 (MPO1)
        Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DM08_Panel_02}/${Module 1A} (${DM08})    ${MPO}${1}-${03}    
        Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE}
        ...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
        Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=3     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${LC_NE_02}/${03}
        ...    objectType=${Trace Switch}     informationDevice=${03}->${LC_NE_02}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_FIBER_FRONT_TO_BACK_CABLING} 
        Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1 (${MPO1})     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DM08_Panel_02}/${Module 1A} (${DM08})/${MPO}${1}-${03} 
        ...    objectType=${TRACE_DM08}     informationDevice=${MPO}${1}-${03}->${Module 1A} (${DM08})->${DM08_Panel_02}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
        Close Trace Window
        
        # + MPO1-04: service box -> connected to -> NE 02/04 -> 6xLC-MPO12 cabled to -> Panel 02/Module 1A/2 (MPO1)
        Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DM08_Panel_02}/${Module 1A} (${DM08})    ${MPO}${1}-${04}    
        Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE}
        ...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
        Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=4     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${LC_NE_02}/${04}
        ...    objectType=${Trace Switch}     informationDevice=${04}->${LC_NE_02}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_FIBER_FRONT_TO_BACK_CABLING} 
        Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=2 (${MPO1})     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DM08_Panel_02}/${Module 1A} (${DM08})/${MPO}${1}-${04} 
        ...    objectType=${TRACE_DM08}     informationDevice=${MPO}${1}-${04}->${Module 1A} (${DM08})->${DM08_Panel_02}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
        Close Trace Window
       
        # + There is no signal on  the pair5 (5-5) and pair6 (6-6). but we still allow users to connect them.
        Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${LC_NE_02}    ${05}
        Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE}
        ...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
        Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${5} [${5-5}]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${LC_NE_02}/${05}
        ...    objectType=${Trace Switch}     informationDevice=${05}->${LC_NE_02}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
        Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=(${MPO1})     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DM08_Panel_02}/${Module 1A} 
        ...    objectType=${TRACE_DM08}     informationDevice=${No Path}->${Module 1A}->${DM08_Panel_02}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
        Close Trace Window
        
        Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${LC_NE_02}    ${06}
        Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE}
        ...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
        Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${6} [${6-6}]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${LC_NE_02}/${06}
        ...    objectType=${Trace Switch}     informationDevice=${06}->${LC_NE_02}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
        Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=(${MPO1})     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DM08_Panel_02}/${Module 1A} 
        ...    objectType=${TRACE_DM08}     informationDevice=${No Path}->${Module 1A}->${DM08_Panel_02}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}   
        Close Trace Window
        
    # 7. Delete NE object in room
        Delete Tree Node On Site Manager    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${LC_NE_02}
        
    # 8. Observe icons of ports, circuit in cabling window
    # _Icons of ports:
        # + Panel 02/Module 1A/MPO1: Available
        Open Cabling Window    
        Check Icon Object On Cabling Tree    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DM08_Panel_02}/${Module 1A} (${DM08})/${MPO} ${01}    ${PortMPOUncabledAvailable}    
        Close Cabling Window
        
    # _The circuit trace displays:
        # MPO1-01: Panel 02/Module 1A/7
        Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DM08_Panel_02}/${Module 1A} (${DM08})    ${MPO}${1}-${01}
        Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=7     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DM08_Panel_02}/${Module 1A} (${DM08})/${MPO}${1}-${01} 
        ...    objectType=${TRACE_DM08}     informationDevice=${MPO}${1}-${01}->${Module 1A} (${DM08})->${DM08_Panel_02}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
        Close Trace Window
        # MPO1-02: Panel 02/Module 1A/8
        Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DM08_Panel_02}/${Module 1A} (${DM08})    ${MPO}${1}-${02}
        Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=8     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DM08_Panel_02}/${Module 1A} (${DM08})/${MPO}${1}-${02} 
        ...    objectType=${TRACE_DM08}     informationDevice=${MPO}${1}-${02}->${Module 1A} (${DM08})->${DM08_Panel_02}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
        Close Trace Window
        # MPO1-03: Panel 02/Module 1A/1
        Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DM08_Panel_02}/${Module 1A} (${DM08})    ${MPO}${1}-${03}
        Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=1     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DM08_Panel_02}/${Module 1A} (${DM08})/${MPO}${1}-${03} 
        ...    objectType=${TRACE_DM08}     informationDevice=${MPO}${1}-${03}->${Module 1A} (${DM08})->${DM08_Panel_02}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
        Close Trace Window
        # MPO1-04: Panel 02/Module 1A/2
        Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DM08_Panel_02}/${Module 1A} (${DM08})    ${MPO}${1}-${04}
        Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=2     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DM08_Panel_02}/${Module 1A} (${DM08})/${MPO}${1}-${04} 
        ...    objectType=${TRACE_DM08}     informationDevice=${MPO}${1}-${04}->${Module 1A} (${DM08})->${DM08_Panel_02}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
        Close Trace Window
        
    # 9. Cabling Panel 03/Module 1A/MPO 01 to CP/01 01-06 and observe
    # _The new MPO12-6xLC ULL Assembly connection type is available
    # _Connect button is disabled
    Open Cabling Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DM12_Panel_03}/${Module 1A} (${DM12})
    Click Tree Node Cabling    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DM12_Panel_03}/${Module 1A} (${DM12})/${MPO} ${01}
    :FOR    ${i}    IN RANGE    0    len(${port_list})
     \    Click Tree Node Cabling    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${CP_NAME}/${port_list}[${i}]
     \    Check Mpo Connection Type State On Cabling Window    mpoConnectionType=${Mpo12_6xLC_EB}    isEnabled=${True}    mpoConnectionTab=${MPO12}
     \    Check Connect Button State On Cabling Window    ${False}              
    
    # 10. Cabling Panel 03/Module 1A/MPO 01 to Panel 01/01-06
    Create Cabling    Connect    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DM12_Panel_03}/${Module 1A} (${DM12})/${MPO} ${01}    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${LC_PANEL_NAME_1}    ${MPO12}    ${Mpo12_6xLC_EB}    ${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}
    ...    portsTo=${01},${02},${03},${04},${05},${06}
   
    # 11. Observe icons of ports, port statuses and trace in Cabling window
    # _Icons of ports:
      # + Panel 03/Module 1A/01: cabled icon
      Check Icon Object On Cabling Tree    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DM12_Panel_03}/${Module 1A} (${DM12})/${MPO} ${01}    ${PortMPOPanelCabledAvailable}
      
      # + Panel 01/01-06: cabled icon
      :FOR    ${i}    IN RANGE    0    len(${port_list})
     \    Check Icon Object On Cabling Tree    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${LC_PANEL_NAME_1}/${port_list}[${i}]    ${PortFDPanelCabledAvailable}
     
    # _Port statuses: 
      # Panel 01/01-06:
        # Port Status: Available
        # Cabled to a panel port.
     \    Check Port Status On Cabling Window    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${LC_PANEL_NAME_1}/${port_list}[${i}]    ${Port Status}: ${Available}    
     \    Check Port Status On Cabling Window    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${LC_PANEL_NAME_1}/${port_list}[${i}]    ${Cabled to a panel port}
    # _The circuit trace displays:
        # Panel 03/Module 1A/1 (MPO1) -> MPO12-6xLC cabled to -> Panel 01/01
        # ...
        # Panel 03/Module 1A/6 (MPO1) -> MPO12-6xLC cabled to -> Panel 01/06
    \    Open Trace Window On Cabling    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${LC_PANEL_NAME_1}/${port_list}[${i}]
    \    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=${object_position_list}[${i}]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${LC_PANEL_NAME_1}/${port_list}[${i}]
    ...    objectType=${TRACE_GENERIC_FIBER_PANEL_IMAGE}     informationDevice=${port_list}[${i}]->${LC_PANEL_NAME_1}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_FIBER_BACK_TO_BACK_CABLING}
    \    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${object_position_list}[${i}] (${MPO}${1})     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DM12_Panel_03}/${Module 1A} (${DM12})/${port_list}[${i}]
    ...    objectType=${TRACE_DM12}     informationDevice=${port_list}[${i}]->${Module 1A} (${DM12})->${DM12_Panel_03}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    \    Close Trace Window   
        
    # 12. Cabling Panel 04/Module 1A/01 to NE 01/01-06
    Create Cabling    Connect    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Insta_Panel_04}/${Module 1A} ${Pass-Through}/${01}    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${LC_NE_01}    ${MPO12}    ${Mpo12_6xLC_EB}    ${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}
    ...    portsTo=${01},${02},${03},${04},${05},${06}
    
    # 13. Observe icons of ports, port statuses and trace in Cabling window
    # _Icons of ports:
      # + Panel 04/Module 1A/01: cabled icon    PortMPOServiceCabledAvailable
          # * Port type is MPO12
      Check Icon Object On Cabling Tree    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Insta_Panel_04}/${Module 1A} ${Pass-Through}/${01}    ${PortMPOServiceCabledAvailable}
      # + Switch 01/01-06: patched icon
      :FOR    ${i}    IN RANGE    0    len(${port_list})
         \    Check Icon Object On Cabling Tree    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${LC_NE_01}/${port_list}[${i}]    ${PortNEFDPanelCabled}
      
    # _Port statuses: 
      # + Panel 04/Module 1A/01:
        # Port Status: Available
        # Cabled to a network equipment port.
      Check Port Status On Cabling Window    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Insta_Panel_04}/${Module 1A} ${Pass-Through}/${01}    ${Port Status}: ${Available}    
      Check Port Status On Cabling Window    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Insta_Panel_04}/${Module 1A} ${Pass-Through}/${01}    ${Cabled to a network equipment port}
      
      # + Switch 01// 01-06:
        # Port Status: Available
        # Cabled to a panel port.
     :FOR    ${i}    IN RANGE    0    len(${port_list}) 
     \    Check Port Status On Cabling Window    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${LC_NE_01}/${port_list}[${i}]    ${Port Status}: ${Available}    
     \    Check Port Status On Cabling Window    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${LC_NE_01}/${port_list}[${i}]    ${Cabled to a panel port}

    # _The circuit trace displays: 
        # + Tab 1-1: service box -> connected to -> NE 01/1 [1-1] -> 6xLC-MPO12 cabled to -> Panel 04/Module 1A/12 1 [/A1]
        # ...
        # + Tab 6-6: service box -> connected to -> NE 01/6 [6-6] -> 6xLC-MPO12 cabled to -> Panel 04/Module 1A/12 1 [/A1]
     \    Open Trace Window On Cabling    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${LC_NE_01}/${port_list}[${i}]
     \    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=     objectPath=${TRACE_CONFIG} /${TRACE_VLAN} /${TRACE_OBJECT_SERVICE}
        ...    objectType=${SERVICE}     informationDevice=${TRACE_OBJECT_SERVICE}->->${TRACE_VLAN}->${TRACE_CONFIG}    connectionType=${TRACE_ASSIGN}
     \    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${object_position_list}[${i}] [${pair_list}[${i}]]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${LC_NE_01}/${port_list}[${i}]
        ...    objectType=${Trace Switch}     informationDevice=${port_list}[${i}]->${LC_NE_01}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
     \    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=${1} [ /${A1}]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Insta_Panel_04}/${Module 1A} ${Pass-Through}/${01}
        ...    objectType=${Trace Generic MPO Panel}     informationDevice=${01}->${Module 1A shortcut} ${Pass-Through}->${MPO_Insta_Panel_04}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
     \    Close Trace Window
     Close Cabling Window
     
SM-29803-05_Verify that user can create/remove F2B cabling MPO12-6xLC ULL Assembly from MPO InstaPatch to LC Generic Panel port
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM29803_05
    ...    AND    Delete Building    ${building_name}
    ...    AND    Open Sm Login Page       
    
    [Teardown]    Run Keywords    Delete Building    ${building_name}    
    ...    AND    Close Browser
 
    ${MPO_Insta_Panel_01}    Set Variable    MPO_Insta_Panel_01
    ${Module 1A shortcut}    Set Variable    ..le 1A
    ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}       
    ${object_position_list}    Create List    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}
    ${pair_list}	Create List    ${Pair 1}    ${Pair 2}    ${Pair 3}    ${Pair 4}    ${Pair 5}    ${Pair 6}
    
    Login To SM    ${USERNAME}    ${PASSWORD}
    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${Quareo Discovery Folder}
    Create Object    buildingName=${building_name}    floorName=${FLOOR_NAME}    roomName=${ROOM_NAME}    rackName=${RACK_NAME}
    # * On SM:
    # 3. Add to Rack 001:
        # _MPO InstaPatch Panel 01
        Add Systimax Fiber Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${360 G2 Fiber Shelf (1U)}    ${MPO_Insta_Panel_01}    Module 1A,${TRUE},MPO (8 Port),${DM 12};Module 1B,${FALSE};Module 1C,${FALSE};Module 1D,${FALSE}
        # _LC Panel 02
        Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${LC_PANEL_NAME_2}    portType=${LC}
        
    # 4. F2B Cabling from Panel 01/Module 1A/01 to Panel 02/01-06
    Open Front To Back Cabling Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Insta_Panel_01}
    Create Front To Back Cabling    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Insta_Panel_01}/${Module 1A} ${Pass-Through}    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${LC_PANEL_NAME_2}
    ...        ${01}    ${01},${02},${03},${04},${05},${06}    Connect    ${MPO12}    ${Mpo12_6xLC_EB}    ${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}    
    
    # 5. Observe new connection type, icons of ports, port statuses and trace in F2B Cabling window
    # _MPO12-6xLC connection type shows with the purple circle for 6 number
    # _Icons of ports:
      # + Panel 01/Module 1A/01: patched icon
      Check Icon Object On Front To Back Cabling Tree    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Insta_Panel_01}/${Module 1A} ${Pass-Through}/${01}    ${PortMPOUncabledInUse}
      # _Port type for Panel 01/Module 1A/01: MPO12    
      Check Icon Mpo Port Type On Cabling Window    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Insta_Panel_01}/${Module 1A} ${Pass-Through}/${01}    12
          
      # + Panel 02/01-06: cabled icon
      :FOR    ${i}    IN RANGE    0    len(${port_list})
      \    Check Icon Object On Cabling Tree    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${LC_PANEL_NAME_2}/${port_list}[${i}]    ${PortFDPanelCabledAvailable}
    
    # _Port statuses:
      # + Panel 01/Module 1A/01: 
        # Port Status: In Use
        # Cable Status: Not Cabled
    Check Port Status On Cabling Window    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Insta_Panel_01}/${Module 1A} ${Pass-Through}/${01}    ${Port Status}: ${In Use} 
    Check Port Status On Cabling Window    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Insta_Panel_01}/${Module 1A} ${Pass-Through}/${01}    ${Not Cabled}    

    # + Panel 02/ 01-06:
        # Port Status: Available
        # Cabled to a panel port.
    :FOR    ${i}    IN RANGE    0    len(${port_list})
    \    Check Port Status On Cabling Window    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${LC_PANEL_NAME_2}/${port_list}[${i}]    ${Port Status}: ${Available}
    \    Check Port Status On Cabling Window    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${LC_PANEL_NAME_2}/${port_list}[${i}]    ${Cabled to a panel port}
    Close Front To Back Cabling Window
               
    # _The circuit displays: 
        # Tab 1-1: Panel 01/Module 1A/12 1 [A1] -> f2b cabled to (MPO12-6xLC) ->  Panel 02/1 [/1-1]
        # Tab 2-2: Panel 01/Module 1A/12 1 [A1] -> f2b cabled to (MPO12-6xLC) ->  Panel 02/2 [/2-2]
        # ...
        # Tab 6-6: Panel 01/Module 1A/12 1 [A1] -> f2b cabled to (MPO12-6xLC) ->  Panel 02/6 [/6-6]
    Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Insta_Panel_01}/${Module 1A} ${Pass-Through}    ${01}
    :FOR    ${i}    IN RANGE    0    len(${port_list})
    \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Trace Object On Site Manager    indexObject=1    mpoType=12    objectPosition=1 [${A1}]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Insta_Panel_01}/${Module 1A} ${Pass-Through}/${01}
    ...    objectType=${Trace Generic MPO Panel}     informationDevice=${01}->${Module 1A shortcut} ${Pass-Through}->${MPO_Insta_Panel_01}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_6X_LC_FRONT_BACK_EB_CABLING}
     \    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${object_position_list}[${i}] [ /${pair_list}[${i}]]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${LC_PANEL_NAME_2}/${port_list}[${i}]
    ...    objectType=${TRACE_GENERIC_FIBER_PANEL_IMAGE}     informationDevice=${port_list}[${i}]->${LC_PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    
    Close Trace Window
        
    # 6. Remove f2b cabling from F2B Cabling window for connection above  
    Remove Cabling By Context Menu On Site Tree    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Insta_Panel_01}    
    Open Front To Back Cabling Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Insta_Panel_01}
       
    # 7. Observe icons of ports, port statuses and trace in F2B Cabling window
    # _Icons of ports:
 	    # +Panel 01/Module 1A/01: no patched icon
 	Check Icon Object On Front To Back Cabling Tree    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Insta_Panel_01}/${Module 1A} ${Pass-Through}/${01}    ${PortMPOUncabledAvailable}
        # + Panel 02/ 01-06: no cabled icon
    :FOR    ${i}    IN RANGE    0    len(${port_list})
     \    Check Icon Object On Cabling Tree    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${LC_PANEL_NAME_2}/${port_list}[${i}]    ${PortFDUncabledAvailable}
    # _Port statuses: Panel 01/Module 1A/01 and Panel 02/ 01-06: 
        # + Port Status: Available
        # + Cable Status: Not Cabled
    Check Port Status On Cabling Window    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Insta_Panel_01}/${Module 1A} ${Pass-Through}/${01}    ${Port Status}: ${Available} 
    Check Port Status On Cabling Window    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Insta_Panel_01}/${Module 1A} ${Pass-Through}/${01}    ${Not Cabled}    
    # _Port type for Panel 01/Module 1A/01: no MPO12 shows
    Check Icon Mpo Port Type On Cabling Window    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Insta_Panel_01}/${Module 1A} ${Pass-Through}/${01}    12    ${FALSE}
    Close Front To Back Cabling Window
        
    # _The circuit displays: 
        # + Panel 01/Module 1A/01
        Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Insta_Panel_01}/${Module 1A} ${Pass-Through}    ${01}
        Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=1     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Insta_Panel_01}/${Module 1A} ${Pass-Through}/${01}
        ...    objectType=${Trace Generic MPO Panel}     informationDevice=${01}->${Module 1A shortcut} ${Pass-Through}->${MPO_Insta_Panel_01}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
        Close Trace Window
       
       # + Panel 02/01, Panel 02/02, Panel 02/03, Panel 02/04, Panel 02/05, Panel 02/06
       :FOR    ${i}    IN RANGE    0    len(${port_list})
       \    Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${LC_PANEL_NAME_2}    ${port_list}[${i}]
       \    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=${object_position_list}[${i}]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${LC_PANEL_NAME_2}/${port_list}[${i}]
        ...    objectType=${TRACE_GENERIC_FIBER_PANEL_IMAGE}     informationDevice=${port_list}[${i}]->${LC_PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    
       \    Close Trace Window
 
SM-29803-06_Verify that user cannot create/remove F2B cabling 6xLC-MPO12/MPO12-6xLC ULL Assembly from InstaPatch (Beta/Alpha) to Equipment port
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM29803_06
    ...    AND    Delete Building    ${building_name}
    ...    AND    Open Sm Login Page       
    
    [Teardown]    Run Keywords    Delete Building    ${building_name}    
    ...    AND    Close Browser
 
    ${Insta_Beta_Panel_01}    Set Variable    InstaPatch Beta Panel 01
    ${Insta_Beta_Panel_01_shortcut}    Set Variable    ..aPatch Beta Panel 01
    ${LC_Panel_Name_3}    Set Variable    LC Panel 03
    ${MPO_Panel_Name_4}    Set Variable    MPO Panel 04
    ${Insta_MPO_Panel_05}    Set Variable    InstaPatch MPO Panel 05
    ${Insta_MPO_Panel_05_shortcut}    Set Variable    ..aPatch MPO Panel 05
    ${Module 1A shortcut}    Set Variable    ..le 1A
    
    ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}       
    ${object_position_list}    Create List    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}
    ${pair_list}	Create List    ${Pair 1}    ${Pair 2}    ${Pair 3}    ${Pair 4}    ${Pair 5}    ${Pair 6}
    
    Login To SM    ${USERNAME}    ${PASSWORD}
    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${Quareo Discovery Folder}
    Create Object    buildingName=${building_name}    floorName=${FLOOR_NAME}    roomName=${ROOM_NAME}    rackName=${RACK_NAME}
        
    # * On SM:
    # 3. Add to Rack 001:
        # _InstaPatch (Beta) Panel 01
    Add Ipatch Fiber Equipment    ${SITE_NODE}/${BUILDING_NAME}/${floor_name}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${360 G2 iPatch - 2U}    ${Insta_Beta_Panel_01}
    ...    ${Module 1A},True,${LC 12 Port},${Beta}
        # _LC Panel 03
    Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${LC_Panel_Name_3}    portType=${LC}
        # _MPO Panel 04
    Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${MPO_Panel_Name_4}    portType=${MPO}
        # _MPO InstaPatch Panel 05
    Add Systimax Fiber Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${360 G2 Fiber Shelf (1U)}    ${Insta_MPO_Panel_05}
    ...    ${Module 1A},${TRUE},${MPO} (8 Port),${DM 12};Module 1B,${FALSE};Module 1C,${FALSE};Module 1D,${FALSE}
    
    # 4. F2B Cabling from Panel 01/Module 1A/01-06 to Panel 04/01 (6xLC-MPO12)   
    Open Front To Back Cabling Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${Insta_Beta_Panel_01}
    Create Front To Back Cabling    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${Insta_Beta_Panel_01}/${Module 1A} (${Beta})    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Panel_Name_4}
    ...        ${01},${02},${03},${04},${05},${06}    ${01}    Connect    mpoType=${Mpo12_6xLC_EB_Symmetry}    mpoTab=${MPO12}    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}
    
    # 5. Observe new connection type, icons of ports, port statuses and trace in F2B Cabling window
    # _MPO12-6xLC connection type shows with the purple circle for 6 number
    # _Icons of ports:
       # + Panel 04/Module 1A/01: cabled icon
       Check Icon Object On Front To Back Cabling Tree    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Panel_Name_4}/${01}    ${PortMPOPanelCabledAvailable}    
       # + Panel 01/01-06: patched icon
       :FOR    ${i}    IN RANGE    0    len(${port_list})
      \    Check Icon Object On Front To Back Cabling Tree    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${Insta_Beta_Panel_01}/${Module 1A} (${Beta})/${port_list}[${i}]    ${PortFDUncabledInUse}
    # _Port statuses:
       # + Panel 01/ 01-06:
            # Port Status: In Use
            # Cable Status: Not Cabled
      \    Check Port Status On Cabling Window    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${Insta_Beta_Panel_01}/${Module 1A} (${Beta})/${port_list}[${i}]    ${Port Status}: ${In Use}
      \    Check Port Status On Cabling Window    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${Insta_Beta_Panel_01}/${Module 1A} (${Beta})/${port_list}[${i}]    ${Not Cabled}         
       # + Panel 04/Module 1A/01: 
            # Port Status: Available
            # Cabled to a panel port.
      Check Port Status On Cabling Window    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Panel_Name_4}/${01}    ${Port Status}: ${Available}
      Check Port Status On Cabling Window    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Panel_Name_4}/${01}    ${Cabled to a panel port}
    # _Port type for Panel 04/Module 1A/01: MPO12
      Check Icon Mpo Port Type On Cabling Window    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Panel_Name_4}/${01}    12
      Close Front To Back Cabling Window
      
    # _The circuit displays: 
        # Tab 1-1: Panel 04/Module 1A/12 1 [A1] -> f2b cabled to (MPO12-6xLC) ->  Panel 01/1 [/1-1]
        # Tab 2-2: Panel 04/Module 1A/12 1 [A1] -> f2b cabled to (MPO12-6xLC) ->  Panel 01/2 [/2-2]
        # ...
        # Tab 6-6: Panel 04/Module 1A/12 1 [A1] -> f2b cabled to (MPO12-6xLC) ->  Panel 01/6 [/6-6]
    Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Panel_Name_4}    ${01}
    :FOR    ${i}    IN RANGE    0    len(${port_list})
    \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
    \    Check Trace Object On Site Manager    indexObject=1    mpoType=12    objectPosition=1 [ /${A1}]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Panel_Name_4}/${01}
    ...    objectType=${Trace Generic MPO Panel}     informationDevice=${01}->${MPO_Panel_Name_4}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_6X_LC_BACK_FRONT_EB_CABLING}
    \    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${object_position_list}[${i}] [${pair_list}[${i}]]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${Insta_Beta_Panel_01}/${Module 1A} (${Beta})/${port_list}[${i}]
    ...    objectType=${Trace iPatch G2 Fiber}     informationDevice=${port_list}[${i}]->${Module 1A} (${Beta})->${Insta_Beta_Panel_01_shortcut}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    
    Close Trace Window
   
    # 6. Select Panel 01/Module 1A/01 port
    # 7. Right-click and select "Remove Cabling" link
    # 8. Continue to remove cabling between Panel 04/Module 1A/01 and Panel 01/01
    Remove Cabling By Context Menu On Content Pane    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${Insta_Beta_Panel_01}/${Module 1A} (${Beta})    ${01}    
    
    # 9. Select  Panel 04/Module 1A/01 and open F2B Cabling window again
    Open Front To Back Cabling Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${Insta_Beta_Panel_01}
    
    # 10. Observe icons of ports, port statuses and trace in F2B Cabling window
    # _Icons of ports:
       # + Panel 01/Module 1A/01: no patched icon
       Check Icon Object On Front To Back Cabling Tree    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${Insta_Beta_Panel_01}/${Module 1A} (${Beta})/${01}    ${PortFDUncabledAvailable}
       # + Panel 01/Module 1A/02-06: patched icon
       :FOR    ${i}    IN RANGE    1    len(${port_list})
      \    Check Icon Object On Front To Back Cabling Tree    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${Insta_Beta_Panel_01}/${Module 1A} (${Beta})/${port_list}[${i}]    ${PortFDUncabledInUse}
       # + Panel 04/01: cabled icon
      Check Icon Object On Front To Back Cabling Tree    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Panel_Name_4}/${01}    ${PortMPOPanelCabledAvailable}
      
    # _Port statuses: 
       # + Panel 01/Module 1A/01:
            # Port Status: Available
            # Cable Status: Not Cabled
       Check Port Status On Cabling Window    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${Insta_Beta_Panel_01}/${Module 1A} (${Beta})/${01}    ${Port Status}: ${Available}
       Check Port Status On Cabling Window    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${Insta_Beta_Panel_01}/${Module 1A} (${Beta})/${01}    ${Not Cabled}
       
       # + Panel 01/Module 1A/02-06:
           # Port Status: In Use
           # Cable Status: Not Cabled
       :FOR    ${i}    IN RANGE    1    len(${port_list})
       \    Check Port Status On Cabling Window    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${Insta_Beta_Panel_01}/${Module 1A} (${Beta})/${port_list}[${i}]    ${Port Status}: ${In Use}
       \    Check Port Status On Cabling Window    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${Insta_Beta_Panel_01}/${Module 1A} (${Beta})/${port_list}[${i}]    ${Not Cabled}
            
       # + Panel 04/ 01:
            # Port Status: Available
            # Cabled to a panel port.
       Check Port Status On Cabling Window    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Panel_Name_4}/${01}    ${Port Status}: ${Available}
       Check Port Status On Cabling Window    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Panel_Name_4}/${01}    ${Cabled to a panel port}
    # _Port type for Panel 04/01: MPO12
       Check Icon Mpo Port Type On Cabling Window    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Panel_Name_4}/${01}    12
       Close Front To Back Cabling Window
       
    # _The circuit displays: 
          # + Panel 01/Module 1A/1
        Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Panel_Name_4}    ${01}
        Check Total Trace On Site Manager    1
        Check Trace Object On Site Manager    indexObject=1    mpoType=12    objectPosition=1 [ /${A1}]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Panel_Name_4}/${01}
        ...    objectType=${Trace Generic MPO Panel}     informationDevice=${01}->${MPO_Panel_Name_4}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_6X_LC_BACK_FRONT_EB_CABLING}
    
          # + Panel 01/Module 1A/2 [2-2] -> f2b cabled to (6xLC-MPO12) ->  Panel 04/12 1 [/A1]
          # ...
          # + Panel 01/Module 1A/6 [6-6] -> f2b cabled to (6xLC-MPO12) ->  Panel 04/12 1 [/A1]
        :FOR    ${i}    IN RANGE    1    len(${port_list})
        \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
        \    Check Trace Object On Site Manager    indexObject=1    mpoType=12    objectPosition=1 [ /${A1}]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Panel_Name_4}/${01}
        ...    objectType=${Trace Generic MPO Panel}     informationDevice=${01}->${MPO_Panel_Name_4}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_6X_LC_BACK_FRONT_EB_CABLING}
        \    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${object_position_list}[${i}] [${pair_list}[${i}]]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${Insta_Beta_Panel_01}/${Module 1A} (${Beta})/${port_list}[${i}]
        ...    objectType=${Trace iPatch G2 Fiber}     informationDevice=${port_list}[${i}]->${Module 1A} (${Beta})->${Insta_Beta_Panel_01_shortcut}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    
        Close Trace Window
          
    # 11. F2B Cabling from Panel 05/Module 1A/01 to Panel 03/01-06 (MPO12-6xLC)
    Open Front To Back Cabling Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${Insta_MPO_Panel_05}/${Module 1A} ${Pass-Through}    ${01}
    Create Front To Back Cabling    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${Insta_MPO_Panel_05}/${Module 1A} ${Pass-Through}    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${LC_Panel_Name_3}
    ...        ${01}    ${01},${02},${03},${04},${05},${06}    Connect    mpoType=${Mpo12_6xLC_EB}    mpoTab=${MPO12}    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}
             
    # 12. Observe icons of ports, port statuses and trace in F2B Cabling window
    # _Icons of ports:
      # + Panel 05/Module 1A/01: patched icon
      Check Icon Object On Front To Back Cabling Tree    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${Insta_MPO_Panel_05}/${Module 1A} ${Pass-Through}/${01}    ${PortMPOUncabledInUse}
      # + Panel 03/01-06: Cabled icon
      :FOR    ${i}    IN RANGE    0    len(${port_list})
      \    Check Icon Object On Front To Back Cabling Tree    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${LC_Panel_Name_3}/${port_list}[${i}]    ${PortFDPanelCabledAvailable}
    # _Port statuses: 
      # + Panel 03/01-06:
        # Port Status: Available
        # Cabled to a panel port
      \    Check Port Status On Cabling Window    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${LC_Panel_Name_3}/${port_list}[${i}]    ${Port Status}: ${Available}
      \    Check Port Status On Cabling Window    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${LC_Panel_Name_3}/${port_list}[${i}]    ${Cabled to a panel port} 
      # + Panel 05/Module 1A/01:
        # Port Status: In Use
        # Cable Status: Not Cabled
        Check Port Status On Cabling Window    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${Insta_MPO_Panel_05}/${Module 1A} ${Pass-Through}/${01}    ${Port Status}: ${In Use}
        Check Port Status On Cabling Window    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${Insta_MPO_Panel_05}/${Module 1A} ${Pass-Through}/${01}    ${Not Cabled}
        
    # _Port type for Panel 05/Module 1A/01: MPO12
        Check Icon Mpo Port Type On Cabling Window    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${Insta_MPO_Panel_05}/${Module 1A} ${Pass-Through}/${01}    12
        Close Front To Back Cabling Window
            
    # _The circuit displays: 
        # Tab 1-1: Panel 05/Module 1A/12 1 [A1] -> f2b (MPO12-6xLC) cabled to -> Panel 03/1 [/1-1]
        # ...
        # Tab 6-6: Panel 05/Module 1A/12 1 [A1] -> f2b (MPO12-6xLC) cabled to -> Panel 03/6 [/6-6]
        Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${Insta_MPO_Panel_05}/${Module 1A} ${Pass-Through}    ${01}
        :FOR    ${i}    IN RANGE    0    len(${port_list})
        \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
        \    Check Trace Object On Site Manager    indexObject=1    mpoType=12    objectPosition=1 [${A1}]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${Insta_MPO_Panel_05}/${Module 1A} ${Pass-Through}/${01}
        ...    objectType=${Trace Generic MPO Panel}     informationDevice=${01}->${Module 1A shortcut} ${Pass-Through}->${Insta_MPO_Panel_05_shortcut}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_6X_LC_FRONT_BACK_EB_CABLING_IMAGE}
        \    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=${object_position_list}[${i}] [ /${pair_list}[${i}]]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${LC_Panel_Name_3}/${port_list}[${i}]
        ...    objectType=${TRACE_GENERIC_FIBER_PANEL_IMAGE}     informationDevice=${port_list}[${i}]->${LC_Panel_Name_3}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    
        Close Trace Window
   
SM-29803-07_Verify that user can create/remove F2B cabling 6xLC-MPO12 ULL Assembly from InstaPatch (DM08/DM12) to Generic Panel port
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM29803_07
    ...    AND    Delete Building    ${building_name}
    ...    AND    Open Sm Login Page       
    
    [Teardown]    Run Keywords    Delete Building    ${building_name}    
    ...    AND    Close Browser
    
    ${DM08_Panel_01}    Set Variable    DM08 Panel 01
    ${DM12_Panel_02}    Set Variable    DM12 Panel 02
    ${MPO_Panel_03}    Set Variable    MPO Panel 03    
    
    ${port_list}    Create List    ${MPO1}-${01}    ${MPO1}-${02}    ${MPO2}-${01}    ${MPO2}-${02}    ${MPO3}-${01}    ${MPO3}-${02}       
    ${object_position_list}    Create List    ${7}    ${8}    ${9}    ${10}    ${11}    ${12}
    ${pair_list}	Create List    ${Pair 1}    ${Pair 2}    ${Pair 3}    ${Pair 4}    ${Pair 5}    ${Pair 6}
    
    Login To SM    ${USERNAME}    ${PASSWORD}
    Create Object    buildingName=${building_name}    floorName=${FLOOR_NAME}    roomName=${ROOM_NAME}    rackName=${RACK_NAME}  
    
    # * On SM:
    # 3. Add to Rack 001:
        # _InstaPatch (DM08) Panel 01
        Add Systimax Fiber Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${360 G2 Fiber Shelf (1U)}    ${DM08_Panel_01}    Module 1A,${TRUE},LC 12 Port,${DM 08};Module 1B,${FALSE};Module 1C,${FALSE};Module 1D,${FALSE}
        # _InstaPatch (DM12) Panel 02
        Add Systimax Fiber Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${360 G2 Fiber Shelf (1U)}    ${DM12_Panel_02}    Module 1A,${TRUE},LC 12 Port,${DM 12};Module 1B,${FALSE};Module 1C,${FALSE};Module 1D,${FALSE}
        # _MPO Generic Panel 03
        Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${MPO_Panel_03}    portType=${MPO}

    # 4. F2B Cabling (6xLC-MPO12) from:
        # _Panel 01/Module 1A/MPO1-01, MPO1-02 to Panel 03/01
        # _Panel 01/Module 1A/MPO2-01, MPO2-02 to Panel 03/01
        # _Panel 01/Module 1A/MPO3-01, MPO3-02 to Panel 03/01
        Open Front To Back Cabling Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DM08_Panel_01}
        Create Front To Back Cabling    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DM08_Panel_01}/${Module 1A} (${DM08})    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Panel_03}
        ...        ${MPO1}-${01},${MPO1}-${02},${MPO2}-${01},${MPO2}-${02},${MPO3}-${01},${MPO3}-${02}    ${01}    Connect    mpoType=${Mpo12_6xLC_EB_Symmetry}    mpoTab=${MPO12}    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}
    
    # 5. Observe icons of ports, port statuses and trace in F2B Cabling window
    # _Icons of ports:
      # + Panel 01/Module 1A/MPO1-01, MPO1-02: patched icon
      # + Panel 01/Module 1A/MPO2-01, MPO2-02: patched icon
      # + Panel 01/Module 1A/MPO3-01, MPO3-02: patched icon
      :FOR    ${i}    IN RANGE    0    len(${port_list})
      \    Check Icon Object On Front To Back Cabling Tree    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DM08_Panel_01}/${Module 1A} (${DM08})/${port_list}[${i}]    ${PortFDUncabledInUse}    
      # + Panel 03/01: cabled icon
      Check Icon Object On Front To Back Cabling Tree    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Panel_03}/${01}    ${PortMPOPanelCabledAvailable}
      
    # _Port statuses:
      # + Panel 01/Module 1A/MPO1-01, MPO1-02:
            # Port Status: In Use
            # Cable Status: Not Cabled
      :FOR    ${i}    IN RANGE    0    len(${port_list})
      \    Check Port Status On Cabling Window    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DM08_Panel_01}/${Module 1A} (${DM08})/${port_list}[${i}]    ${Port Status}: ${In Use}
      \    Check Port Status On Cabling Window    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DM08_Panel_01}/${Module 1A} (${DM08})/${port_list}[${i}]    ${Not Cabled}       
     
      # + Panel 03/01:
            # Port Status: Available
            # Cabled to a panel port.
    # _Port type for 
      # + Panel 03/01: MPO12
        Check Port Status On Cabling Window    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Panel_03}/${01}    ${Port Status}: ${Available}
        Check Port Status On Cabling Window    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Panel_03}/${01}    ${Cabled to a panel port}
        Check Icon Mpo Port Type On Cabling Window    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Panel_03}/${01}    12
        Close Front To Back Cabling Window
        
    # _The circuit displays: 
        # Panel 01/Module 1A/MPO1-01:
        # Panel 01/Module 1A/7 [1-1] -> f2b cabled to -> Panel 03/12 1 [/A1]
        # Panel 01/Module 1A/MPO1-02:
        # Panel 01/Module 1A/8 [2-2] -> f2b cabled to -> Panel 03/12 1 [/A1]
        # ...
        # Panel 01/Module 1A/MPO3-02:
        # Panel 01/Module 1A/12 [6-6] -> f2b cabled to -> Panel 03/12 1 [/A1]
        :FOR    ${i}    IN RANGE    0    len(${port_list})
    \    Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DM08_Panel_01}/${Module 1A} (${DM08})    ${port_list}[${i}]
    \    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=${object_position_list}[${i}] [${pair_list}[${i}]]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DM08_Panel_01}/${Module 1A} (${DM08})/${port_list}[${i}]
    ...    objectType=${Trace DM08}     informationDevice=${port_list}[${i}]->${Module 1A} (${DM08})->${DM08_Panel_01}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
    \    Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=${1} [ /${A1}]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Panel_03}/${01}
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}     informationDevice=${01}->${MPO_Panel_03}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    
    \    Close Trace Window
        
    # 6. Select Panel 01/Module 1A/01 port
    # 7. Delete Panel 01 in Rack 001
    Delete Tree Node On Site Manager    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DM08_Panel_01}
    
    # 8. Select Panel 03/01 and observe icons of ports, port statuses in F2B Cabling window
    Open Front To Back Cabling Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Panel_03}
    
    # _Icons of ports: no cabled or patched icon
    Check Icon Object On Front To Back Cabling Tree    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Panel_03}/${01}    ${PortMPOUncabledAvailable}
    
    # _Port statuses: 
        # Port Status: Available
        # Cable Status: Not Cabled
    Check Port Status On Cabling Window    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Panel_03}/${01}    ${Port Status}: ${Available}
    Check Port Status On Cabling Window    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Panel_03}/${01}    ${Not Cabled}
    
    ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}       
    ${object_position_list}    Create List    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}
    ${pair_list}	Create List    ${Pair 1}    ${Pair 2}    ${Pair 3}    ${Pair 4}    ${Pair 5}    ${Pair 6}
        
    # 9. F2B Cabling (6xLC-MPO12) from Panel 02/Module 1A/01-06 to Panel 03/01
    Create Front To Back Cabling    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DM12_Panel_02}/${Module 1A} (${DM12})    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Panel_03}
    ...    ${01},${02},${03},${04},${05},${06}    ${01}    Connect    mpoType=${Mpo12_6xLC_EB_Symmetry}    mpoTab=${MPO12}    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}
    
    # 10. Observe icons of ports, port statuses and trace in F2B Cabling window
    # _Icons of ports:
      # + Panel 02/Module 1A/01-06: patched icon
      :FOR    ${i}    IN RANGE    0    len(${port_list})
      \    Check Icon Object On Front To Back Cabling Tree    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DM12_Panel_02}/${Module 1A} (${DM12})/${port_list}[${i}]    ${PortFDUncabledInUse}
      # + Panel 03/01: cabled icon
      Check Icon Object On Front To Back Cabling Tree    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Panel_03}/${01}    ${PortMPOPanelCabledAvailable}
      
    # _Port statuses:
      # + Panel 02/Module 1A/01-06
            # Port Status: In Use
            # Cable Status: Not Cabled
      :FOR    ${i}    IN RANGE    0    len(${port_list})
      \    Check Port Status On Cabling Window    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DM12_Panel_02}/${Module 1A} (${DM12})/${port_list}[${i}]    ${Port Status}: ${In Use}
      \    Check Port Status On Cabling Window    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DM12_Panel_02}/${Module 1A} (${DM12})/${port_list}[${i}]    ${Not Cabled}
      # + Panel 03/01:
            # Port Status: Available
            # Cabled to a panel port.
      # _Port type for Panel 03/01: MPO12
      Check Port Status On Cabling Window    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Panel_03}/${01}    ${Port Status}: ${Available}
      Check Port Status On Cabling Window    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Panel_03}/${01}    ${Cabled to a panel port}
      Check Icon Mpo Port Type On Cabling Window    To    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Panel_03}/${01}    12
      Close Front To Back Cabling Window
    
    # _The circuit displays: 
        # Panel 02/Module 1A/1 [1-1] -> f2b cabled to -> Panel 03/12 1 [/A1]
        # ...
        # Panel 02/Module 1A/6 [6-6] -> f2b cabled to -> Panel 03/12 1 [/A1]
      :FOR    ${i}    IN RANGE    0    len(${port_list})
    \    Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DM12_Panel_02}/${Module 1A} (${DM12})    ${port_list}[${i}]
    \    Check Trace Object On Site Manager    indexObject=1    mpoType=None    objectPosition=${object_position_list}[${i}] [${pair_list}[${i}]]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${DM12_Panel_02}/${Module 1A} (${DM12})/${port_list}[${i}]
    ...    objectType=${Trace DM12}     informationDevice=${port_list}[${i}]->${Module 1A} (${DM12})->${DM12_Panel_02}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}
    \    Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=${1} [ /${A1}]     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MPO_Panel_03}/${01}
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}     informationDevice=${01}->${MPO_Panel_03}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    
    \    Close Trace Window