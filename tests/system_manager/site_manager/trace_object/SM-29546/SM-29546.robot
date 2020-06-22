*** Settings ***
Resource    ../../../../../resources/constants.robot
Resource    ../../../../../resources/icons_constants.robot

Library   ../../../../../py_sources/logigear/setup.py
Library   ../../../../../py_sources/logigear/api/BuildingApi.py    ${USERNAME}    ${PASSWORD}           
Library   ../../../../../py_sources/logigear/page_objects/system_manager/login/LoginPage${PLATFORM}.py  
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/SiteManagerPage${PLATFORM}.py 
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/cabling/CablingPage${PLATFORM}.py       
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/patching/PatchingPage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/front_to_back_cabling/FrontToBackCablingPage${PLATFORM}.py
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/work_orders/create_work_order/CreateWorkOrderPage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/history/circuit_history/CircuitHistoryPage${PLATFORM}.py

Default Tags    Trace Object
Force Tags    SM-29546

*** Variables ***
${FLOOR_NAME}    Floor 01 
${ROOM_NAME}    Room 01
${RACK_NAME}    Rack 01
${POSITION_RACK_NAME}    1:1 Rack 01
${SWITCH_NAME}    Switch 01
${SWITCH_NAME_2}    Switch 02
${PORT_NAME}    Port 01
${NEP_NAME_1}    NEP 01
${NEP_NAME_2}    NEP 02
${NEP_NAME_3}    NEP 03
${NEP_NAME_4}    NEP 04
${CARD_NAME_1}    Card 01
${CARD_NAME_2}    Card 02
${CARD_NAME_3}    Card 03
${GBIC_NAME_1}    GBIC Slot 01
${GBIC_NAME_2}    GBIC Slot 02
${GBIC_NAME_3}    GBIC Slot 03
${POE_NAME}    PoE 01
${PANEL_NAME}    Panel 01
${PANEL_NAME_2}    Panel 02
${MF_NAME}    Mainframe 01
${POSITION_MF_NAME}    1:1 ${MF_NAME}
${MF_FRAME_NAME}    Frame 01
${MF_CAGE}    Cage 01
${MF_FRAME_INTERFACE}    Interface 01
${TRACE_TAB_01}    Uplink: Port 2
${FP_NAME}    Faceplate 01
${PERSON_LAST_NAME}    LName
${DEVICE_TYPE}    Computer
${DEVICE_NAME_1}    Device 01
${DEVICE_NAME_2}    Device 02
${MEDIA_CONVERT_NAME}    Media Converter 01
${SPLICE_ENCLOSURE_NAME}    Enclosure 01
${SPLICE_TRAY_NAME}    Tray 01
${SERVER_NAME}    Server 01
${TRACE_TITLE}     Switch Port 01
${UPLINK_ICON_BASELINE}    uplink_trace_black.png
${UPLINK_ICON_ON_TRACE}    uplink_trace.png
${DIR_UPLINK_ICON}    ${DIR_PRECONDITION_PICTURE}\\${UPLINK_ICON_BASELINE}
${LOC_UPLINK_ICON}    ${DIR_NAVICONS_COMMSCOPE}\\${UPLINK_ICON_ON_TRACE}

*** Test Cases ***
SM-29546_01_Verify That The Trace Window With The Uplink Tabs For Switch Are Displayed When Clicking On The Toggle Button
    [Teardown]    Run Keywords    Delete Tree Node On Site Manager    ${SITE_NODE}/${cablevault_name}     
    ...    AND    Close Browser
    
    Set Tags    SM-29888

    ${cablevault_name} =    Set Variable    CV_SM29546_01
	${trace_tab_02} =     Set Variable    Uplink: Card 4/Port 2 
	${trace_tab_03} =     Set Variable    Uplink: GBIC 6/Port 2
	${trace_tab_04} =     Set Variable    Uplink: Card 5/GBIC 25/Port 2
 
    # 1. Launch and log into SM Web
    # 2. Go to "Site Manager" page
   
    Open SM Login Page
    Login To SM    ${USERNAME}    ${PASSWORD}

    Delete Tree Node If Exist On Site Manager     ${SITE_NODE}/${cablevault_name}

    # 3. Add Switch 01 to Rack 001
    # 4. Add to Switch 01:
    # _Some ports (RJ-45, LC, MPO)
    # _Card 01 with some ports (RJ-45, LC, MPO)
    # _GBIC Slot 01 with some ports (RJ-45, LC, MPO)
    # _Card 02/ GBIC Slot 02 with some ports (RJ-45, LC, MPO)
    # 5. Set "Uplink Port" to:
    # _Switch 01/ 02
    # _Switch 01/ Card 01/ 02
    # _Switch 01/ GBIC Slot 01/ 02
    # _Switch 01/ Card 02/ GBIC Slot 02/ 02
    Add Cable Vault    ${SITE_NODE}        ${cablevault_name}
    Add Rack    ${SITE_NODE}/${cablevault_name}    ${RACK_NAME}
    Add Network Equipment    ${SITE_NODE}/${cablevault_name}/${POSITION_RACK_NAME}    ${SWITCH_NAME}
    Add Network Equipment Port    ${SITE_NODE}/${cablevault_name}/${POSITION_RACK_NAME}/${SWITCH_NAME}    name=${NEP_NAME_1}    portType=${RJ-45}                             
    Add Network Equipment Port    ${SITE_NODE}/${cablevault_name}/${POSITION_RACK_NAME}/${SWITCH_NAME}    name=${NEP_NAME_2}    portType=${LC}    uplinkPort=yes                         
    Add Network Equipment Port    ${SITE_NODE}/${cablevault_name}/${POSITION_RACK_NAME}/${SWITCH_NAME}    name=${NEP_NAME_3}    portType=${MPO12}                             
    Add Network Equipment Component    ${SITE_NODE}/${cablevault_name}/${POSITION_RACK_NAME}/${SWITCH_NAME}    Network Equipment Card    ${CARD_NAME_1}    portType=${RJ-45}    quantity=2
    Add Network Equipment Component    ${SITE_NODE}/${cablevault_name}/${POSITION_RACK_NAME}/${SWITCH_NAME}    Network Equipment GBIC Slot    ${GBIC_NAME_1}   portType=${RJ-45}    totalPorts=12
    Add Network Equipment Component    ${SITE_NODE}/${cablevault_name}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${CARD_NAME_2}    Network Equipment GBIC Slot    ${GBIC_NAME_2}   portType=${RJ-45}    totalPorts=12
    Edit Port On Content Table    ${SITE_NODE}/${cablevault_name}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${CARD_NAME_2}/${GBIC_NAME_2}    name=02    portType=${LC}    uplinkPort=yes
    Edit Port On Content Table    ${SITE_NODE}/${cablevault_name}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${CARD_NAME_2}/${GBIC_NAME_2}    name=03    portType=${MPO12}
    Edit Port On Content Table    ${SITE_NODE}/${cablevault_name}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${CARD_NAME_1}    name=02    portType=${LC}    uplinkPort=yes
    Edit Port On Content Table    ${SITE_NODE}/${cablevault_name}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${CARD_NAME_1}    name=03    portType=${MPO12}
    Edit Port On Content Table    ${SITE_NODE}/${cablevault_name}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${GBIC_NAME_1}    name=02    portType=${LC}    uplinkPort=yes
    Edit Port On Content Table    ${SITE_NODE}/${cablevault_name}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${GBIC_NAME_1}    name=03    portType=${MPO12}
    
    # 6. Trace Switch 01/ 01 (or any normal port)
    # 7. Observe the result
    Open Trace Window    ${SITE_NODE}/${cablevault_name}/${POSITION_RACK_NAME}/${SWITCH_NAME}    ${NEP_NAME_1}
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1   objectPath=${SITE_NODE}/${cablevault_name}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_1}    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${cablevault_name}->${SITE_NODE}
    Uplink Button Should Be Visible On Trace Of Site Manager
    Compare Images    ${DIR_UPLINK_ICON}    ${LOC_UPLINK_ICON}
    Uplink Button Should Be Enabled On Trace Of Site Manager  
    Select View Trace Tab On Site Manager    ${TRACE_TAB_01}
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2   objectPath=${SITE_NODE}/${cablevault_name}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_2}    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_2}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${cablevault_name}->${SITE_NODE}
    Select View Trace Tab On Site Manager    ${trace_tab_02}
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2   objectPath=${SITE_NODE}/${cablevault_name}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${CARD_NAME_1}/02    objectType=${TRACE_NON_SWITCH_CARD_IMAGE}    informationDevice=02->${CARD_NAME_1}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${cablevault_name}->${SITE_NODE}
    Select View Trace Tab On Site Manager    ${trace_tab_03}
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2   objectPath=${SITE_NODE}/${cablevault_name}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${GBIC_NAME_1}/02    objectType=${TRACE_SWITCH_IMAGE}   informationDevice=02->${GBIC_NAME_1}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${cablevault_name}->${SITE_NODE}
    Select View Trace Tab On Site Manager    ${trace_tab_04}       
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2   objectPath=${SITE_NODE}/${cablevault_name}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${CARD_NAME_2}/${GBIC_NAME_2}/02    objectType=${TRACE_NON_SWITCH_CARD_IMAGE}    informationDevice=02->${GBIC_NAME_2}->${CARD_NAME_2}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${cablevault_name}->${SITE_NODE}
    
    # 8. On the Trace window, click on the "Show/Hide Uplink Tabs" toggle button
    Click Uplink Button On Site Manager    
    Uplink Tab Should Not Be Visible On Trace Of Site Manager  
    
    # 9. On the Trace window, click on the "Show/Hide Uplink Tabs" toggle button
    Click Uplink Button On Site Manager    
    Uplink Tab Should Be Visible On Trace Of Site Manager
    Uplink Button Should Be Enabled On Trace Of Site Manager
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1   objectPath=${SITE_NODE}/${cablevault_name}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_1}    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${cablevault_name}->${SITE_NODE}
    Uplink Button Should Be Visible On Trace Of Site Manager
    Select View Trace Tab On Site Manager    ${TRACE_TAB_01}
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2   objectPath=${SITE_NODE}/${cablevault_name}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_2}    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_2}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${cablevault_name}->${SITE_NODE}
    Select View Trace Tab On Site Manager    ${trace_tab_02}
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2   objectPath=${SITE_NODE}/${cablevault_name}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${CARD_NAME_1}/02    objectType=${TRACE_NON_SWITCH_CARD_IMAGE}    informationDevice=02->${CARD_NAME_1}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${cablevault_name}->${SITE_NODE}
    Select View Trace Tab On Site Manager    ${trace_tab_03}
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2   objectPath=${SITE_NODE}/${cablevault_name}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${GBIC_NAME_1}/02    objectType=${TRACE_SWITCH_IMAGE}   informationDevice=02->${GBIC_NAME_1}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${cablevault_name}->${SITE_NODE}
    Select View Trace Tab On Site Manager    ${trace_tab_04}       
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2   objectPath=${SITE_NODE}/${cablevault_name}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${CARD_NAME_2}/${GBIC_NAME_2}/02    objectType=${TRACE_NON_SWITCH_CARD_IMAGE}    informationDevice=02->${GBIC_NAME_2}->${CARD_NAME_2}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${cablevault_name}->${SITE_NODE}

    # 10. Continue to click on the "Show/Hide Uplink Tabs" toggle button to show the uplink tabs
    Click Uplink Button On Site Manager    
    Close Trace Window
    
    # 11. Trace Switch 01/ 02 (or any uplink port
    Open Trace Window    ${SITE_NODE}/${cablevault_name}/${POSITION_RACK_NAME}/${SWITCH_NAME}    ${NEP_NAME_2}
    
    # 12. Observe the result
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2   objectPath=${SITE_NODE}/${cablevault_name}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_2}    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_2}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${cablevault_name}->${SITE_NODE}
    Uplink Button Should Be Visible On Trace Of Site Manager
    Uplink Button Should Be Disabled On Trace Of Site Manager    
    
    # 13. On the Trace window, click on the "Show/Hide Uplink Tabs" toggle button
    # 14. Observe the result
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2   objectPath=${SITE_NODE}/${cablevault_name}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_2}    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_2}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${cablevault_name}->${SITE_NODE}
    Uplink Button Should Be Visible On Trace Of Site Manager
    Close Trace Window
    
    # 15. Trace Switch 01/01, change Direction to Vertical when Uplink tabs are being shown
    Open Trace Window    ${SITE_NODE}/${cablevault_name}/${POSITION_RACK_NAME}/${SWITCH_NAME}    ${NEP_NAME_1}
    Switch View Mode On Trace               
    
    # 16. Select any Uplink tab
    Uplink Button Should Be Enabled On Trace Of Site Manager
    Select View Trace Tab On Site Manager    ${TRACE_TAB_01}->${trace_tab_02}->${trace_tab_03}->${trace_tab_04}
    
    # 17. Observe the result
    Check Trace Table Exist On Site Manager
    Close Trace Window  

SM-29546_02_Verify That The Trace Window With The Uplink Tabs For Managed Switch Are Displayed When Clicking On The Toggle Button
    [Teardown]    Run Keywords    Delete Tree Node On Site Manager    ${SITE_NODE}/${cablevault_name}    
    ...    AND    Close Browser
      
    [Tags]    Sanity
    
    Set Tags    SM-29888

    ${cablevault_name} =    Set Variable    CV_SM29546_02
    ${ip_v4_address} =    Set Variable    10.50.7.54
    ${mne_path} =    Set Variable    C:\\Pre Condition\\SNMP\\Original\\SyncSwitch ${ip_v4_address}.txt
    ${mne_name} =    Set Variable    MNE_01
	${trace_tab_02} =     Set Variable    Uplink: Card 1/Port 2 
	${trace_tab_03} =     Set Variable    Uplink: Card 1/GBIC 1/Port 1
	${trace_tab_04} =     Set Variable    Uplink: GBIC 3/Port 1 
		
	Copy File    ${mne_path}    ${TEST_DATA_PATH}

	# 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	Open SM Login Page
    Login To SM    ${USERNAME}    ${PASSWORD}

    Delete Tree Node If Exist On Site Manager     ${SITE_NODE}/${cablevault_name}
	
	# 3. Add a managed Switch 01 (with Card, GBIC Slot, Card/ GBIC Slot and Ports directly) with RJ-45, LC, MPO port types to Rack 001 and sync it successfully
	# 4. Set "Uplink Port" to:
	# _Switch 01/ 02
	# _Switch 01/ Card 01/ 02
	# _Switch 01/ GBIC Slot 01/ 02
	# _Switch 01/ Card 02/ GBIC Slot 02/ 02
	Add Cable Vault    ${SITE_NODE}        ${cablevault_name}
    Add Rack    ${SITE_NODE}/${cablevault_name}    ${RACK_NAME}
    Add Managed Switch    ${SITE_NODE}/${cablevault_name}/${POSITION_RACK_NAME}    ${mne_name}    ${ip_v4_address}    IPv4    False                        
    Synchronize Managed Switch    ${SITE_NODE}/${cablevault_name}/${POSITION_RACK_NAME}/${mne_name}   
    
    # 5. Trace Switch 01/ 01 (or any normal port)
    Open Trace Window    ${SITE_NODE}/${cablevault_name}/${POSITION_RACK_NAME}/${mne_name}    01
    
    # 6. Observe the result
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1   objectPath=${SITE_NODE}/${cablevault_name}/${POSITION_RACK_NAME}/${mne_name}/01    objectType=${TRACE_MANAGED_SWITCH_IMAGE}    informationDevice=01->${mne_name}->IP: ${ip_v4_address}->${POSITION_RACK_NAME}->${cablevault_name}->${SITE_NODE}
    Uplink Button Should Be Visible On Trace Of Site Manager
    Compare Images    ${DIR_UPLINK_ICON}    ${LOC_UPLINK_ICON}  
    Uplink Button Should Be Enabled On Trace Of Site Manager 
    Select View Trace Tab On Site Manager    ${TRACE_TAB_01}
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2   objectPath=${SITE_NODE}/${cablevault_name}/${POSITION_RACK_NAME}/${mne_name}/02    objectType=${TRACE_MANAGED_SWITCH_IMAGE}    informationDevice=02->${mne_name}->IP: ${ip_v4_address}->${POSITION_RACK_NAME}->${cablevault_name}->${SITE_NODE}
    Select View Trace Tab On Site Manager    ${trace_tab_02}
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2   objectPath=${SITE_NODE}/${cablevault_name}/${POSITION_RACK_NAME}/${mne_name}/${CARD_NAME_1}/02    objectType=${TRACE_SWITCH_CARD_IMAGE}    informationDevice=02->${CARD_NAME_1}->${mne_name}->IP: ${ip_v4_address}->${POSITION_RACK_NAME}->${cablevault_name}->${SITE_NODE}
    Select View Trace Tab On Site Manager    ${trace_tab_03}
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1   objectPath=${SITE_NODE}/${cablevault_name}/${POSITION_RACK_NAME}/${mne_name}/${CARD_NAME_1}/${GBIC_NAME_1}/01    objectType=${TRACE_SWITCH_CARD_IMAGE}    informationDevice=01->${GBIC_NAME_1}->${CARD_NAME_1}->${mne_name}->IP: ${ip_v4_address}->${POSITION_RACK_NAME}->${cablevault_name}->${SITE_NODE}
    Select View Trace Tab On Site Manager    ${trace_tab_04}
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1   objectPath=${SITE_NODE}/${cablevault_name}/${POSITION_RACK_NAME}/${mne_name}/${GBIC_NAME_3}/01    objectType=${TRACE_MANAGED_SWITCH_IMAGE}    informationDevice=01->${GBIC_NAME_3}->${mne_name}->IP: ${ip_v4_address}->${POSITION_RACK_NAME}->${cablevault_name}->${SITE_NODE}
    
    # 7. On the Trace window, click on the "Show/Hide Uplink Tabs" toggle button
    Click Uplink Button On Site Manager
    Uplink Tab Should Not Be Visible On Trace Of Site Manager
    Uplink Button Should Be Enabled On Trace Of Site Manager
    
    # 8. On the Trace window, click on the "Show/Hide Uplink Tabs" toggle button
    Click Uplink Button On Site Manager
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1   objectPath=${SITE_NODE}/${cablevault_name}/${POSITION_RACK_NAME}/${mne_name}/01    objectType=${TRACE_MANAGED_SWITCH_IMAGE}    informationDevice=01->${mne_name}->IP: ${ip_v4_address}->${POSITION_RACK_NAME}->${cablevault_name}->${SITE_NODE}
    Select View Trace Tab On Site Manager    ${TRACE_TAB_01}
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2   objectPath=${SITE_NODE}/${cablevault_name}/${POSITION_RACK_NAME}/${mne_name}/02    objectType=${TRACE_MANAGED_SWITCH_IMAGE}    informationDevice=02->${mne_name}->IP: ${ip_v4_address}->${POSITION_RACK_NAME}->${cablevault_name}->${SITE_NODE}
    Select View Trace Tab On Site Manager    ${trace_tab_02}
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2   objectPath=${SITE_NODE}/${cablevault_name}/${POSITION_RACK_NAME}/${mne_name}/${CARD_NAME_1}/02    objectType=${TRACE_SWITCH_CARD_IMAGE}    informationDevice=02->${CARD_NAME_1}->${mne_name}->IP: ${ip_v4_address}->${POSITION_RACK_NAME}->${cablevault_name}->${SITE_NODE}
    Select View Trace Tab On Site Manager    ${trace_tab_03}
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1   objectPath=${SITE_NODE}/${cablevault_name}/${POSITION_RACK_NAME}/${mne_name}/${CARD_NAME_1}/${GBIC_NAME_1}/01    objectType=${TRACE_SWITCH_CARD_IMAGE}    informationDevice=01->${GBIC_NAME_1}->${CARD_NAME_1}->${mne_name}->IP: ${ip_v4_address}->${POSITION_RACK_NAME}->${cablevault_name}->${SITE_NODE}
    Select View Trace Tab On Site Manager    ${trace_tab_04}
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1   objectPath=${SITE_NODE}/${cablevault_name}/${POSITION_RACK_NAME}/${mne_name}/${GBIC_NAME_3}/01    objectType=${TRACE_MANAGED_SWITCH_IMAGE}    informationDevice=01->${GBIC_NAME_3}->${mne_name}->IP: ${ip_v4_address}->${POSITION_RACK_NAME}->${cablevault_name}->${SITE_NODE}
   
    # 9. Continue to click on the "Show/Hide Uplink Tabs" toggle button to show the uplink tabs
    Click Uplink Button On Site Manager
    Close Trace Window    

    # 10. Trace Switch 01/ 02 (or any uplink port)
    Open Trace Window    ${SITE_NODE}/${cablevault_name}/${POSITION_RACK_NAME}/${mne_name}    02
    
    # 11. Observe the result
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2   objectPath=${SITE_NODE}/${cablevault_name}/${POSITION_RACK_NAME}/${mne_name}/02    objectType=${TRACE_MANAGED_SWITCH_IMAGE}    informationDevice=02->${mne_name}->IP: ${ip_v4_address}->${POSITION_RACK_NAME}->${cablevault_name}->${SITE_NODE}
    Uplink Button Should Be Visible On Trace Of Site Manager
    Uplink Button Should Be Disabled On Trace Of Site Manager
    
    # 12. On the Trace window, click on the "Show/Hide Uplink Tabs" toggle button
	# 13. Observe the result
    Uplink Button Should Be Visible On Trace Of Site Manager
    Uplink Button Should Be Disabled On Trace Of Site Manager
    Close Trace Window
    
SM-29546_03_Verify That The Trace Window With The Uplink Tabs Are Displayed With Circuit: Switch In Rack -> Patched To -> Panel -> Cabled To -> Switch In Rack; Switch In Rack -> Cabled To -> Panel -> Patched To -> Mainframe (And Poe)
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM29546_03
    ...    AND    Delete Building     name=${building_name}
    ...    AND    Add New Building    ${building_name} 
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}   
    
    [Teardown]    Run Keywords    Delete Building     name=${building_name}
    ...    AND    Close Browser
    
	${trace_tab_02} =     Set Variable    Uplink: Port 3  

    # 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
    ######RJ Type####
	# 3. Add to Rack 001:
	# _Switch 01 (managed or non-managed) with some ports (RJ-45, LC, MPO)
	# _Panel 01 (RJ-45, LC, MPO)
	# _Switch 02 (managed or non-managed) with some ports (RJ-45, LC, MPO)
	# _PoE 01
	# 4. Add Mainframe 001/ Frame 01/ Cage 01/ Card 01/ Interface 01
	# 5. Set "Uplink Port" for Switch 01// 02, 03
    Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME}
    Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME}
    Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_NAME}
    Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${SWITCH_NAME}    ${RJ-45}
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    name=${NEP_NAME_1}    portType=${RJ-45}
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    name=${NEP_NAME_2}    portType=${RJ-45}    uplinkPort=yes    quantity=2
    Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${SWITCH_NAME_2}    ${RJ-45}
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}    name=${NEP_NAME_1}    portType=${RJ-45}
    Add PoE Device    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${POE_NAME}
    Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    name=${PANEL_NAME}    quantity=1
    Add Mainframe    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${MF_NAME}
    Add Mainframe Object    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_MF_NAME}    Frame    ${MF_FRAME_NAME}    
    Add Mainframe Object    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_MF_NAME}/${MF_FRAME_NAME}    Mainframe Cage    ${MF_CAGE}    
    Add Mainframe Object    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_MF_NAME}/${MF_FRAME_NAME}/${MF_CAGE}    Mainframe Cage Card    ${CARD_NAME_1}    
    Add Mainframe Object    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_MF_NAME}/${MF_FRAME_NAME}/${MF_CAGE}/${CARD_NAME_1}    Mainframe Interface    ${MF_FRAME_INTERFACE}    portType=${RJ-45}    totalPort=1    
    
    # 6. Cable from:
	# _Panel 01// 01 to Switch 02// 01
	# _Switch 01// 02 to Panel 01// 02
	# _Switch 01// 03 to Panel 01// 03
    Open Cabling Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    01
    Create Cabling    cableFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01    cableTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}
    ...    portsTo=${NEP_NAME_1}
    Create Cabling    cableFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_2}    cableTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}
    ...    portsTo=02
    Create Cabling    cableFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_3}    cableTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}
    ...    portsTo=03
    Close Cabling Window
    
	# 7. Create Add Patch and complete the job from:
	# _Switch 01// 01 to Panel 01// 01
	# _Panel 01// 02 to Mainframe 001// 02
	# _Panel 01// 03 to PoE 01// 03 D
    Open Patching Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    ${NEP_NAME_1}
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}
    ...    portsFrom=${NEP_NAME_1}    portsTo=01    clickNext=${False}
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_MF_NAME}/${MF_FRAME_NAME}/${MF_CAGE}/${CARD_NAME_1}/${MF_FRAME_INTERFACE}
    ...    portsFrom=02    portsTo=01    clickNext=${False}
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${POE_NAME}
    ...    portsFrom=03    portsTo=01 D    createWo=${False}    clickNext=${True}
   
    # 8. Trace Switch 01// 01
	# 9. Observe the result

    Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    ${NEP_NAME_1}
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_1}
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_COPPER_PATCHING}    
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01    
    ...    objectType=${TRACE_GENERIC_RJ_PANEL_IMAGE}    informationDevice=01->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_COPPER_BACK_TO_FRONT_CABLING}    
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}/${NEP_NAME_1}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
 
    Select View Trace Tab On Site Manager    ${TRACE_TAB_01}
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_2}
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_2}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_COPPER_FRONT_TO_BACK_CABLING}    
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/02
    ...    objectType=${TRACE_GENERIC_RJ_PANEL_IMAGE}    informationDevice=02->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_COPPER_PATCHING}    
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_MF_NAME}/${MF_FRAME_NAME}/${MF_CAGE}/${CARD_NAME_1}/${MF_FRAME_INTERFACE}/01    
    ...    objectType=${TRACE_MF_CAGE_CARD_IMAGE}    informationDevice=01->${MF_FRAME_INTERFACE}->${CARD_NAME_1}->${MF_CAGE}->${MF_FRAME_NAME}->${POSITION_MF_NAME}->${ROOM_NAME}->${FLOOR_NAME}
 
    Select View Trace Tab On Site Manager    ${trace_tab_02}
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=3    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_3}
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_3}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_COPPER_FRONT_TO_BACK_CABLING}    
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=3    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/03    
    ...    objectType=${TRACE_GENERIC_RJ_PANEL_IMAGE}    informationDevice=03->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_COPPER_PATCHING}    
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${POE_NAME}/01 D    
    ...    objectType=${TRACE_POE_IMAGE}    informationDevice=01 D->${POE_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_SPLICE_INTERNAL_CONNECT_TYPE}
    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${POE_NAME}/01 D&P    
    ...    objectType=${TRACE_POE_IMAGE}    informationDevice=01 D&P->${POE_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
 
	# 10. On the Trace window, click on the "Show/Hide Uplink Tabs" toggle button
	# 11. Observe the result
    Click Uplink Button On Site Manager    
    Uplink Tab Should Not Be Visible On Trace Of Site Manager

	# 12. On the Trace window, click on the "Show/Hide Uplink Tabs" toggle button
	# 13. Observe the result    
    Click Uplink Button On Site Manager
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_1}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_COPPER_PATCHING}    
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01    
    ...    objectType=${TRACE_GENERIC_RJ_PANEL_IMAGE}    informationDevice=01->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_COPPER_BACK_TO_FRONT_CABLING}    
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}/${NEP_NAME_1}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
 
    Select View Trace Tab On Site Manager    ${TRACE_TAB_01}
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_2}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_2}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_COPPER_FRONT_TO_BACK_CABLING}    
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/02    
    ...    objectType=${TRACE_GENERIC_RJ_PANEL_IMAGE}    informationDevice=02->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_COPPER_PATCHING}    
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_MF_NAME}/${MF_FRAME_NAME}/${MF_CAGE}/${CARD_NAME_1}/${MF_FRAME_INTERFACE}/01    
    ...    objectType=${TRACE_MF_CAGE_CARD_IMAGE}    informationDevice=01->${MF_FRAME_INTERFACE}->${CARD_NAME_1}->${MF_CAGE}->${MF_FRAME_NAME}->${POSITION_MF_NAME}->${ROOM_NAME}->${FLOOR_NAME}
 
    Select View Trace Tab On Site Manager    ${trace_tab_02}
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=3    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_3}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_3}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_COPPER_FRONT_TO_BACK_CABLING}    
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=3    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/03    
    ...    objectType=${TRACE_GENERIC_RJ_PANEL_IMAGE}    informationDevice=03->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_COPPER_PATCHING}    
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${POE_NAME}/01 D    
    ...    objectType=${TRACE_POE_IMAGE}    informationDevice=01 D->${POE_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_SPLICE_INTERNAL_CONNECT_TYPE}
    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${POE_NAME}/01 D&P    
    ...    objectType=${TRACE_POE_IMAGE}    informationDevice=01 D&P->${POE_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window

    #####LC Type####
    
    Delete Tree Node On Site Manager     ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    

    Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME}
    Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_NAME}
    Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${SWITCH_NAME}    
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    name=${NEP_NAME_1}    portType=${LC}
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    name=${NEP_NAME_2}    portType=${LC}    uplinkPort=yes    quantity=2
    Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${SWITCH_NAME_2}    
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}    name=${NEP_NAME_1}    portType=${LC}
    Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    name=${PANEL_NAME}    portType=${LC}    quantity=1    
    Add Mainframe    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${MF_NAME}
    Add Mainframe Object    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_MF_NAME}    Frame    ${MF_FRAME_NAME}    
    Add Mainframe Object    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_MF_NAME}/${MF_FRAME_NAME}    Mainframe Cage    ${MF_CAGE}    
    Add Mainframe Object    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_MF_NAME}/${MF_FRAME_NAME}/${MF_CAGE}    Mainframe Cage Card    ${CARD_NAME_1}    
    Add Mainframe Object    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_MF_NAME}/${MF_FRAME_NAME}/${MF_CAGE}/${CARD_NAME_1}    Mainframe Interface    ${MF_FRAME_INTERFACE}    portType=${LC}    totalPort=1    
    
    Open Cabling Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    01
    Create Cabling    cableFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01    cableTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}
    ...    portsTo=${NEP_NAME_1}
    Create Cabling    cableFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_2}    cableTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}
    ...    portsTo=02
    Create Cabling    cableFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_3}    cableTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}
    ...    portsTo=03
    Close Cabling Window
    
    Open Patching Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    01        
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}
    ...    portsFrom=${NEP_NAME_1}    portsTo=01    clickNext=${False}   
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_MF_NAME}/${MF_FRAME_NAME}/${MF_CAGE}/${CARD_NAME_1}/${MF_FRAME_INTERFACE}
    ...    portsFrom=02    portsTo=01    createWo=${False}    clickNext=${True}
   
    Open Trace Window    Site/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    ${NEP_NAME_1}
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_1}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_FIBER_PATCHING}    
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01    
    ...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    informationDevice=01->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_FIBER_BACK_TO_FRONT_CABLING}    
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}/${NEP_NAME_1}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
 
    Select View Trace Tab On Site Manager    ${TRACE_TAB_01}
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_2}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_2}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_FIBER_FRONT_TO_BACK_CABLING}    
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/02    
    ...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    informationDevice=02->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_FIBER_PATCHING}    
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_MF_NAME}/${MF_FRAME_NAME}/${MF_CAGE}/${CARD_NAME_1}/${MF_FRAME_INTERFACE}/01    
    ...    objectType=${TRACE_MF_CAGE_CARD_IMAGE}    informationDevice=01->${MF_FRAME_INTERFACE}->${CARD_NAME_1}->${MF_CAGE}->${MF_FRAME_NAME}->${POSITION_MF_NAME}->${ROOM_NAME}->${FLOOR_NAME}
 
    Select View Trace Tab On Site Manager    ${trace_tab_02}
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=3    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_3}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_3}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_FIBER_FRONT_TO_BACK_CABLING}    
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=3    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/03    
    ...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    informationDevice=03->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    
 
    Click Uplink Button On Site Manager    
    Uplink Tab Should Not Be Visible On Trace Of Site Manager  
    
    Click Uplink Button On Site Manager    
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_1}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_FIBER_PATCHING}    
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01    
    ...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    informationDevice=01->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_FIBER_BACK_TO_FRONT_CABLING}    
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}/${NEP_NAME_1}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
 
    Select View Trace Tab On Site Manager    ${TRACE_TAB_01}
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_2}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_2}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_FIBER_FRONT_TO_BACK_CABLING}    
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/02    
    ...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    informationDevice=02->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_FIBER_PATCHING}    
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_MF_NAME}/${MF_FRAME_NAME}/${MF_CAGE}/${CARD_NAME_1}/${MF_FRAME_INTERFACE}/01    
    ...    objectType=${TRACE_MF_CAGE_CARD_IMAGE}    informationDevice=01->${MF_FRAME_INTERFACE}->${CARD_NAME_1}->${MF_CAGE}->${MF_FRAME_NAME}->${POSITION_MF_NAME}->${ROOM_NAME}->${FLOOR_NAME}
 
    Select View Trace Tab On Site Manager    ${trace_tab_02}
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=3    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_3}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_3}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_FIBER_FRONT_TO_BACK_CABLING}    
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=3    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/03    
    ...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    informationDevice=03->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    
    Close Trace Window
    
    #####MPO Type####
    
    Delete Tree Node If Exist On Site Manager     ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    

    Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME}
    Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_NAME}
    Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${SWITCH_NAME}    
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    name=${NEP_NAME_1}    portType=${MPO12}
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    name=${NEP_NAME_2}    portType=${MPO12}    uplinkPort=yes    quantity=2
    Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${SWITCH_NAME_2}   
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}    name=${NEP_NAME_1}    portType=${MPO12}
    Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    name=${PANEL_NAME}    portType=${MPO}    quantity=1    
    
    Open Cabling Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    01
    Create Cabling    cableFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01    cableTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}
    ...    portsTo=${NEP_NAME_1}
    Create Cabling    cableFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_2}    cableTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}
    ...    portsTo=02
    Create Cabling    cableFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_3}    cableTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}
    ...    portsTo=03
    Close Cabling Window
    
    Open Patching Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    01        
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}
    ...    portsFrom=${NEP_NAME_1}    portsTo=01    createWo=${False}    clickNext=${True}   
   
    Open Trace Window    Site/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    ${NEP_NAME_1}
    Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_1}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_PATCHING}    
    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01     
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=01->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_MPO12_BACK_TO_FRONT_CABLING}    
    Check Trace Object On Site Manager    indexObject=4    mpoType=12    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}/${NEP_NAME_1}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
 
    Select View Trace Tab On Site Manager    ${TRACE_TAB_01}
    Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_2}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_2}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}    
    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/02    
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=02->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}         
 
    Select View Trace Tab On Site Manager    ${trace_tab_02}
    Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=3    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_3}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_3}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}    
    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=3    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/03    
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=03->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    

    Click Uplink Button On Site Manager    
    Uplink Tab Should Not Be Visible On Trace Of Site Manager  
    
    Click Uplink Button On Site Manager    
    Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_1}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_PATCHING}    
    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01     
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=01->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_MPO12_BACK_TO_FRONT_CABLING}    
    Check Trace Object On Site Manager    indexObject=4    mpoType=12    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}/${NEP_NAME_1}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
 
    Select View Trace Tab On Site Manager    ${TRACE_TAB_01}
    Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_2}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_2}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}    
    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/02    
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=02->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}         
 
    Select View Trace Tab On Site Manager    ${trace_tab_02}
    Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=3    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_3}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_3}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}    
    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=3    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/03    
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=03->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    
    Close Trace Window

SM-29546_04_Verify That The Trace Window With The Uplink Tabs Are Displayed With Circuit: Switch In Rack -> Patched To -> Panel -> Cabled To -> Faceplate -> Patched To -> Device -> Assigned To -> Person
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM29546_04
    ...    AND    Delete Building     name=${building_name}
    ...    AND    Add New Building    ${building_name} 
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}   
    
    [Teardown]    Run Keywords    Delete Building     name=${building_name}
    ...    AND    Close Browser
    
    # 1. Launch and log into SM Web
    # 2. Go to "Site Manager" page
    #####RJ Type####
    # 3. Add:
    # _Rack 001, Faceplate 01 (RJ-45, LC), Person 01, Device 01-02 (assigned to Person)
    # _Panel 01 (RJ-45, LC), Switch 01 (managed or non-managed) with some ports (RJ-45, LC) to Rack 001
    # 4. Set "Uplink Port" for Switch 01// 02
    Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME}
    Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME}
    Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_NAME}
    Add Faceplate    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${FP_NAME}
    Add Person    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    firstName=01    lastName=${PERSON_LAST_NAME}
    Add Device    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${DEVICE_TYPE}    ${DEVICE_NAME_1}    ${PERSON_LAST_NAME}, 01                        
    Add Device    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${DEVICE_TYPE}    ${DEVICE_NAME_2}    ${PERSON_LAST_NAME}, 01                        
    Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${PANEL_NAME}
    Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${SWITCH_NAME}
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    name=${NEP_NAME_1}    portType=${RJ-45}
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    name=${NEP_NAME_2}    portType=${RJ-45}    uplinkPort=yes
      
    # 5. Cable from Panel 01// 01-02 to Faceplate 01/ 01-02
    Open Cabling Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    01
    Create Cabling    cableFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01
    ...    cableTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${FP_NAME}    portsTo=01
    Create Cabling    cableFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/02
    ...    cableTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${FP_NAME}    portsTo=02
    Close Cabling Window
    
    # 6. Create Add Patch and complete the job from:
    # _Switch 01// 01-02 to Panel 01// 01-02
    # _Faceplate 01/ 01-02 to Device 01-02// 01-02
    Open Patching Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    ${NEP_NAME_1}
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}
    ...    portsFrom=${NEP_NAME_1}    portsTo=01    createWo=${True}    clickNext=${False}
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}
    ...    portsFrom=${NEP_NAME_2}    portsTo=02    createWo=${True}    clickNext=${False}
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${FP_NAME}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}
    ...    portsFrom=01    portsTo=${DEVICE_NAME_1}    createWo=${True}    clickNext=${False}
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${FP_NAME}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}
    ...    portsFrom=02    portsTo=${DEVICE_NAME_2}    createWo=${False}    clickNext=${True}  
    
    # 7. Trace Switch 01// 01
    Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    ${NEP_NAME_1}
    
    # 8. Observe the result
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_1}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_COPPER_PATCHING}     
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01    
    ...    objectType=${TRACE_GENERIC_RJ_PANEL_IMAGE}    informationDevice=01->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_COPPER_BACK_TO_BACK_CABLING}    
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${FP_NAME}/01    
    ...    objectType=${TRACE_RJ_FACEPLATE_IMAGE}    informationDevice=01->${FP_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_COPPER_PATCHING} 
    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${DEVICE_NAME_1}    
    ...    objectType=${TRACE_COMPUTER_IMAGE}    informationDevice=${DEVICE_NAME_1}    connectionType=${TRACE_CONNECT_TYPE}    
    Check Trace Object On Site Manager    indexObject=6    mpoType=None    objectPosition=${PERSON_LAST_NAME}, 01   objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${PERSON_LAST_NAME}, 01    
    ...    objectType=${TRACE_PERSON_IMAGE}    informationDevice=${PERSON_LAST_NAME}, 01 
    # 9. On the Trace window, click on the "Show/Hide Uplink Tabs" toggle button
	Click Uplink Button On Site Manager    

	# 10. Observe the result
    Uplink Tab Should Not Be Visible On Trace Of Site Manager
   
    # 11. On the Trace window, click on the "Show/Hide Uplink Tabs" toggle button
    Click Uplink Button On Site Manager    
    
    # 12. Observe the result
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_1}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_COPPER_PATCHING}     
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01    
    ...    objectType=${TRACE_GENERIC_RJ_PANEL_IMAGE}    informationDevice=01->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_COPPER_BACK_TO_BACK_CABLING}    
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${FP_NAME}/01    
    ...    objectType=${TRACE_RJ_FACEPLATE_IMAGE}    informationDevice=01->${FP_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_COPPER_PATCHING} 
    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${DEVICE_NAME_1}    
    ...    objectType=${TRACE_COMPUTER_IMAGE}    informationDevice=${DEVICE_NAME_1}     connectionType=${TRACE_CONNECT_TYPE}    
    Check Trace Object On Site Manager    indexObject=6    mpoType=None    objectPosition=${PERSON_LAST_NAME}, 01   objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${PERSON_LAST_NAME}, 01    
    ...    objectType=${TRACE_PERSON_IMAGE}    informationDevice=${PERSON_LAST_NAME}, 01->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window
    
    #####LC Type####
    
    Delete Tree Node On Site Manager     ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    
    
    Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME}
    Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_NAME}
    Add Faceplate    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${FP_NAME}    outletType=${LC}
    Add Person    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    firstName=01    lastName=${PERSON_LAST_NAME}
    Add Device    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${DEVICE_TYPE}    ${DEVICE_NAME_1}    ${PERSON_LAST_NAME}, 01                         
    Add Device    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${DEVICE_TYPE}    ${DEVICE_NAME_2}    ${PERSON_LAST_NAME}, 01                         
    Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${PANEL_NAME}    portType=${LC}
    Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${SWITCH_NAME}
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    name=${NEP_NAME_1}    portType=${LC}
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    name=${NEP_NAME_2}    portType=${LC}    uplinkPort=yes
      
    Open Cabling Window
    Create Cabling    cableFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01
    ...    cableTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${FP_NAME}    portsTo=01
    Create Cabling    cableFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/02
    ...    cableTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${FP_NAME}    portsTo=02
    Close Cabling Window
    
    Open Patching Window
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}
    ...    portsFrom=${NEP_NAME_1}    portsTo=01    createWo=${True}    clickNext=${False}
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}
    ...    portsFrom=${NEP_NAME_2}    portsTo=02    createWo=${True}    clickNext=${False}
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${FP_NAME}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}
    ...    portsFrom=01    portsTo=${DEVICE_NAME_1}    createWo=${True}    clickNext=${False}
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${FP_NAME}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}
    ...    portsFrom=02    portsTo=${DEVICE_NAME_2}    createWo=${False}    clickNext=${True}   
    
    Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    ${NEP_NAME_1}
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_1}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_FIBER_PATCHING}    
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01    
    ...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    informationDevice=01->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_FIBER_BACK_TO_BACK_CABLING}    
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${FP_NAME}/01    
    ...    objectType=${TRACE_RJ_FACEPLATE_IMAGE}    informationDevice=01->${FP_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_FIBER_PATCHING}
    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${DEVICE_NAME_1}    
    ...    objectType=${TRACE_COMPUTER_IMAGE}    informationDevice=${DEVICE_NAME_1}     connectionType=${TRACE_CONNECT_TYPE}    
    Check Trace Object On Site Manager    indexObject=6    mpoType=None    objectPosition=${PERSON_LAST_NAME}, 01   objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${PERSON_LAST_NAME}, 01    
    ...    objectType=${TRACE_PERSON_IMAGE}    informationDevice=${PERSON_LAST_NAME}, 01->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}

	Click Uplink Button On Site Manager    
    Uplink Tab Should Not Be Visible On Trace Of Site Manager  
 
    Click Uplink Button On Site Manager
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_1}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_FIBER_PATCHING}    
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01    
    ...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    informationDevice=01->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_FIBER_BACK_TO_BACK_CABLING}    
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${FP_NAME}/01    
    ...    objectType=${TRACE_RJ_FACEPLATE_IMAGE}    informationDevice=01->${FP_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_FIBER_PATCHING}
    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=     objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${DEVICE_NAME_1}    
    ...    objectType=${TRACE_COMPUTER_IMAGE}    informationDevice=${DEVICE_NAME_1}     connectionType=${TRACE_CONNECT_TYPE}    
    Check Trace Object On Site Manager    indexObject=6    mpoType=None    objectPosition=${PERSON_LAST_NAME}, 01   objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${PERSON_LAST_NAME}, 01    
    ...    objectType=${TRACE_PERSON_IMAGE}    informationDevice=${PERSON_LAST_NAME}, 01->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window

SM-29546_05_Verify That The Trace Window With The Uplink Tabs Are Displayed With Circuit: Switch In Rack -> Cabled To -> Panel <- F2B Cabling <- MC -> Patched To -> Panel -> Cabled To -> Switch
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM29546_05
    ...    AND    Delete Building     name=${building_name}
    ...    AND    Add New Building    ${building_name} 
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}   
    
    [Teardown]    Run Keywords    Delete Building     name=${building_name}
    ...    AND    Close Browser

    # 1. Launch and log into SM Web
    # 2. Go to "Site Manager" page
    # 3. Add to Rack 001: 
	# _RJ-45 Switch 01 (managed or non-managed) with some ports
	# _RJ-45 Panel 01
	# _Media Converter 01
	# _LC Panel 02
	# _LC Switch 02 (managed or non-managed) with some ports
	# 4. Set "Uplink Port" for Switch 01// 02
    Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME}
    Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME}
    Add Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${RACK_NAME}
    Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${SWITCH_NAME}
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    name=${NEP_NAME_1}    portType=${RJ-45}
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    name=${NEP_NAME_2}    portType=${RJ-45}    uplinkPort=yes
    Add Media Converter    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${MEDIA_CONVERT_NAME}
    Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${SWITCH_NAME_2}
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}    name=${NEP_NAME_1}    portType=${LC}
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}    name=${NEP_NAME_2}    portType=${LC}
    Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${PANEL_NAME}    portType=${RJ-45}
    Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${PANEL_NAME_2}    portType=${LC}

    # 5. Create Cable:
    # _Panel 02// 01-02 to Switch 02// 01-02
    Open Cabling Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}    01
    Create Cabling    cableFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}/01
    ...    cableTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}    portsTo=${NEP_NAME_1}
    Create Cabling    cableFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}/02
    ...    cableTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}    portsTo=${NEP_NAME_2}
    Close Cabling Window
    
    # 6. F2B cabling from: 
	# _MC 01/ 01 Copper to Panel 01// 01
	# _MC 01/ 02 Copper to Panel 01// 02
    Open Front To Back Cabling Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${MEDIA_CONVERT_NAME}     
    Create Front To Back Cabling    cabFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MEDIA_CONVERT_NAME}    cabTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}
    ...    portsFrom=01 Copper    portsTo=01      
    Create Front To Back Cabling    cabFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MEDIA_CONVERT_NAME}    cabTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}
    ...    portsFrom=02 Copper    portsTo=02
    Close Front To Back Cabling Window

    # 7. Create Add Patch and complete the job from: 
	# _Switch 01// 01-02 to Panel 01// 01-02
	# _MC 01/ 01 Fiber to Panel 02// 01
	# _MC 01/ 02 Fiber to Panel 02// 02
    Open Patching Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    ${NEP_NAME_1}        
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}
    ...    portsFrom=${NEP_NAME_1}    portsTo=01    createWo=${True}    clickNext=${False}
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}
    ...    portsFrom=${NEP_NAME_2}    portsTo=02    createWo=${True}    clickNext=${False}
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MEDIA_CONVERT_NAME}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}
    ...    portsFrom=01 Fiber     portsTo=01    createWo=${True}    clickNext=${False}
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MEDIA_CONVERT_NAME}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}
    ...    portsFrom=02 Fiber     portsTo=02    createWo=${False}    clickNext=${True}    
    
    # 8. Trace Switch 01// 01
    Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    ${NEP_NAME_1}

    # 9. Observe the result
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_1}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_COPPER_PATCHING}
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01    
    ...    objectType=${TRACE_GENERIC_RJ_PANEL_IMAGE}    informationDevice=01->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_COPPER_BACK_TO_FRONT_CABLING}    
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MEDIA_CONVERT_NAME}/01 Copper 
    ...    objectType=${TRACE_MEDIA_CONVERT_IMAGE}    informationDevice=01 Copper->${MEDIA_CONVERT_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_SPLICE_INTERNAL_CONNECT_TYPE}
    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MEDIA_CONVERT_NAME}/01 Fiber 
    ...    objectType=${TRACE_MEDIA_CONVERT_IMAGE}    informationDevice=01 Fiber->${MEDIA_CONVERT_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_FIBER_PATCHING}
    Check Trace Object On Site Manager    indexObject=6    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}/01 
    ...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    informationDevice=01->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_FIBER_BACK_TO_FRONT_CABLING}
    Check Trace Object On Site Manager    indexObject=7    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}/${NEP_NAME_1} 
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    
    # 10. On the Trace window, click on the "Show/Hide Uplink Tabs" toggle button
	Click Uplink Button On Site Manager

	# 11. Observe the result
    Uplink Tab Should Not Be Visible On Trace Of Site Manager
   
    # 12. On the Trace window, click on the "Show/Hide Uplink Tabs" toggle button
    Click Uplink Button On Site Manager    
    
    # 13. Observe the result
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_1}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_COPPER_PATCHING}
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01    
    ...    objectType=${TRACE_GENERIC_RJ_PANEL_IMAGE}    informationDevice=01->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_COPPER_BACK_TO_FRONT_CABLING}    
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MEDIA_CONVERT_NAME}/01 Copper 
    ...    objectType=${TRACE_MEDIA_CONVERT_IMAGE}    informationDevice=01 Copper->${MEDIA_CONVERT_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_SPLICE_INTERNAL_CONNECT_TYPE}
    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${MEDIA_CONVERT_NAME}/01 Fiber 
    ...    objectType=${TRACE_MEDIA_CONVERT_IMAGE}    informationDevice=01 Fiber->${MEDIA_CONVERT_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_FIBER_PATCHING}
    Check Trace Object On Site Manager    indexObject=6    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME_2}/01 
    ...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    informationDevice=01->${PANEL_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_FIBER_BACK_TO_FRONT_CABLING}
    Check Trace Object On Site Manager    indexObject=7    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}/${NEP_NAME_1} 
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window

SM-29546_06_Verify that the Trace window with the uplink tabs are displayed with circuit: Switch in Rack -> patched to -> Panel -> cabled to -> Splice
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM29546_06
    ...    AND    Delete Building     name=${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}   
    
    [Teardown]    Run Keywords    Delete Building     name=${building_name}
    ...    AND    Close Browser
    
    ${trace_tab_02} =    Set Variable    Port 1
    ${nep_name_01_b} =     Set Variable    ${NEP_NAME_1} B
    ${nep_name_01_a} =     Set Variable    ${NEP_NAME_1} A
    ${nep_name_02_b} =     Set Variable    ${NEP_NAME_2} B
    ${nep_name_02_a} =     Set Variable    ${NEP_NAME_2} A
    
    # 1. Launch and log into SM Web
    # 2. Go to "Site Manager" page
    # 3. Add: 
	# _Rack 001, Fiber Splice Enclosure 01/ Tray 01 to Room 01
	# _LC Panel 01, LC Switch 01 (managed or non-managed) with some ports to Rack 001
	# 4. Set "Uplink Port" for Switch 01// 02
	Create Object    buildingName=${building_name}    floorName=${FLOOR_NAME}    roomName=${ROOM_NAME}    rackName=${RACK_NAME}
    Add Splice Enclosure    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    name=${SPLICE_ENCLOSURE_NAME}   
    Add Splice Tray    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SPLICE_ENCLOSURE_NAME}    name=${SPLICE_TRAY_NAME}    spliceType=${FIBER}    
    Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${PANEL_NAME}    portType=${LC}   
    Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${SWITCH_NAME}
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    name=${NEP_NAME_1}    portType=${LC}
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    name=${NEP_NAME_2}    portType=${LC}    uplinkPort=True
    
	# 5. Cable from: 	
	# _Panel 01// 01 to Splice Enclosure 01/ Tray 01/ 01 In - 02 In
	# _Panel 01// 02 to Splice Enclosure 01/ Tray 01/ 03 In - 04 In
	Open Cabling Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    01
    Create Cabling    cableFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01
    ...    cableTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SPLICE_ENCLOSURE_NAME}/${SPLICE_TRAY_NAME}    portsTo=01 In
    Create Cabling    cableFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/02
    ...    cableTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SPLICE_ENCLOSURE_NAME}/${SPLICE_TRAY_NAME}    portsTo=03 In
    Close Cabling Window

	# 6. Create Add Patch and complete the job from: 
	# _Switch 01// 01-02 to Panel 01// 01-02
    Open Patching Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    ${NEP_NAME_1}        
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}
    ...    portsFrom=${NEP_NAME_1}    portsTo=01    createWo=${True}    clickNext=${False}
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}
    ...    portsFrom=${NEP_NAME_2}    portsTo=02    createWo=${False}    clickNext=${True}

	# 7. Trace Switch 01// 01
    Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    ${NEP_NAME_1}
	
	# 8. Observe the result
	# _The Trace window for Switch Port 01 is displayed.
	# _The circuit trace for Switch Port 01 displays: 
	# +First Path: Switch 01// 01 A -> patched to -> Panel 01// 01 B -> cabled to -> Splice Enclosure 01/ Tray 01/ 02 In -> connected to -> Splice Enclosure 01/ Tray 01/ 02 Out
	# +Second Path: Switch 01// 01 B -> patched to -> Panel 01// 01 A -> cabled to -> Splice Enclosure 01/ Tray 01/ 01 In -> connected to -> Splice Enclosure 01/ Tray 01/ 01 Out
	Select View Trace Tab On Site Manager    ${trace_tab_02}->${FIRST_PATH}        
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${nep_name_01_b}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${nep_name_01_b}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_FIBER_PATCHING}
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01 A   
    ...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    informationDevice=01 A->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_FIBER_BACK_TO_BACK_CABLING}    
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SPLICE_ENCLOSURE_NAME}/${SPLICE_TRAY_NAME}/01 In
    ...    objectType=${TRACE_SPLICE_ENCLOSURE_IMAGE}    informationDevice=01 In->${SPLICE_TRAY_NAME}->${SPLICE_ENCLOSURE_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_SPLICE_INTERNAL_CONNECT_TYPE}
    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SPLICE_ENCLOSURE_NAME}/${SPLICE_TRAY_NAME}/01 Out 
    ...    objectType=${TRACE_SPLICE_ENCLOSURE_IMAGE}    informationDevice=01 Out->${SPLICE_TRAY_NAME}->${SPLICE_ENCLOSURE_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}

	Select View Trace Tab On Site Manager    ${trace_tab_02}->${SECOND_PATH}        
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${nep_name_01_a}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${nep_name_01_a}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_FIBER_PATCHING}
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01 B   
    ...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    informationDevice=01 B->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_FIBER_BACK_TO_BACK_CABLING}    
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=3    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SPLICE_ENCLOSURE_NAME}/${SPLICE_TRAY_NAME}/02 In
    ...    objectType=${TRACE_SPLICE_ENCLOSURE_IMAGE}    informationDevice=02 In->${SPLICE_TRAY_NAME}->${SPLICE_ENCLOSURE_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_SPLICE_INTERNAL_CONNECT_TYPE}
    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=4    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SPLICE_ENCLOSURE_NAME}/${SPLICE_TRAY_NAME}/02 Out 
    ...    objectType=${TRACE_SPLICE_ENCLOSURE_IMAGE}    informationDevice=02 Out->${SPLICE_TRAY_NAME}->${SPLICE_ENCLOSURE_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}

	# _One more uplink tab is displayed with circuit: 
	# +First Path: Switch 01// 02 A -> patched to -> Panel 01// 02 B -> cabled to -> Splice Enclosure 01/ Tray 01/ 04 In -> connected to -> Splice Enclosure 01/ Tray 01/ 04 Out
	# +Second Path: Switch 01// 02 B -> patched to -> Panel 01// 02 A -> cabled to -> Splice Enclosure 01/ Tray 01/ 03 In -> connected to -> Splice Enclosure 01/ Tray 01/ 03 Out
	Select View Trace Tab On Site Manager    ${TRACE_TAB_01}->${FIRST_PATH}        
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${nep_name_02_b}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${nep_name_02_b}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_FIBER_PATCHING}
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/02 A   
    ...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    informationDevice=02 A->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_FIBER_BACK_TO_BACK_CABLING}    
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=5    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SPLICE_ENCLOSURE_NAME}/${SPLICE_TRAY_NAME}/03 In
    ...    objectType=${TRACE_SPLICE_ENCLOSURE_IMAGE}    informationDevice=03 In->${SPLICE_TRAY_NAME}->${SPLICE_ENCLOSURE_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_SPLICE_INTERNAL_CONNECT_TYPE}
    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=6    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SPLICE_ENCLOSURE_NAME}/${SPLICE_TRAY_NAME}/03 Out 
    ...    objectType=${TRACE_SPLICE_ENCLOSURE_IMAGE}    informationDevice=03 Out->${SPLICE_TRAY_NAME}->${SPLICE_ENCLOSURE_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}

	Select View Trace Tab On Site Manager    ${TRACE_TAB_01}->${SECOND_PATH}        
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${nep_name_02_a}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${nep_name_02_a}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_FIBER_PATCHING}
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/02 B   
    ...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    informationDevice=02 B->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_FIBER_BACK_TO_BACK_CABLING}    
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=7    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SPLICE_ENCLOSURE_NAME}/${SPLICE_TRAY_NAME}/04 In
    ...    objectType=${TRACE_SPLICE_ENCLOSURE_IMAGE}    informationDevice=04 In->${SPLICE_TRAY_NAME}->${SPLICE_ENCLOSURE_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_SPLICE_INTERNAL_CONNECT_TYPE}
    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=8    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SPLICE_ENCLOSURE_NAME}/${SPLICE_TRAY_NAME}/04 Out 
    ...    objectType=${TRACE_SPLICE_ENCLOSURE_IMAGE}    informationDevice=04 Out->${SPLICE_TRAY_NAME}->${SPLICE_ENCLOSURE_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    
    # 9. On the Trace window, click on the "Show/Hide Uplink Tabs" toggle button
	Click Uplink Button On Site Manager

	# 10. Observe the result
	# * Step 10: The uplink tab is disappeared in the Trace window.
	Uplink Tab Should Not Be Visible On Trace Of Site Manager
	
	# 11. On the Trace window, click on the "Show/Hide Uplink Tabs" toggle button
	Click Uplink Button On Site Manager

	# 12. Observe the result
	# * Step 12: The uplink tab is displayed again in the Trace window as step 8.
    # _The Trace window for Switch Port 01 is displayed.
	# _The circuit trace for Switch Port 01 displays: 
	# +First Path: Switch 01// 01 A -> patched to -> Panel 01// 01 B -> cabled to -> Splice Enclosure 01/ Tray 01/ 02 In -> connected to -> Splice Enclosure 01/ Tray 01/ 02 Out
	# +Second Path: Switch 01// 01 B -> patched to -> Panel 01// 01 A -> cabled to -> Splice Enclosure 01/ Tray 01/ 01 In -> connected to -> Splice Enclosure 01/ Tray 01/ 01 Out
	Select View Trace Tab On Site Manager    ${trace_tab_02}->${FIRST_PATH}        
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${nep_name_01_b}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${nep_name_01_b}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_FIBER_PATCHING}
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01 A   
    ...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    informationDevice=01 A->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_FIBER_BACK_TO_BACK_CABLING}    
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SPLICE_ENCLOSURE_NAME}/${SPLICE_TRAY_NAME}/01 In
    ...    objectType=${TRACE_SPLICE_ENCLOSURE_IMAGE}    informationDevice=01 In->${SPLICE_TRAY_NAME}->${SPLICE_ENCLOSURE_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_SPLICE_INTERNAL_CONNECT_TYPE}
    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SPLICE_ENCLOSURE_NAME}/${SPLICE_TRAY_NAME}/01 Out 
    ...    objectType=${TRACE_SPLICE_ENCLOSURE_IMAGE}    informationDevice=01 Out->${SPLICE_TRAY_NAME}->${SPLICE_ENCLOSURE_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}

	Select View Trace Tab On Site Manager    ${trace_tab_02}->${SECOND_PATH}        
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${nep_name_01_a}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${nep_name_01_a}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_FIBER_PATCHING}
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01 B   
    ...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    informationDevice=01 B->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_FIBER_BACK_TO_BACK_CABLING}    
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=3    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SPLICE_ENCLOSURE_NAME}/${SPLICE_TRAY_NAME}/02 In
    ...    objectType=${TRACE_SPLICE_ENCLOSURE_IMAGE}    informationDevice=02 In->${SPLICE_TRAY_NAME}->${SPLICE_ENCLOSURE_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_SPLICE_INTERNAL_CONNECT_TYPE}
    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=4    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SPLICE_ENCLOSURE_NAME}/${SPLICE_TRAY_NAME}/02 Out 
    ...    objectType=${TRACE_SPLICE_ENCLOSURE_IMAGE}    informationDevice=02 Out->${SPLICE_TRAY_NAME}->${SPLICE_ENCLOSURE_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}

	# _One more uplink tab is displayed with circuit: 
	# +First Path: Switch 01// 02 A -> patched to -> Panel 01// 02 B -> cabled to -> Splice Enclosure 01/ Tray 01/ 04 In -> connected to -> Splice Enclosure 01/ Tray 01/ 04 Out
	# +Second Path: Switch 01// 02 B -> patched to -> Panel 01// 02 A -> cabled to -> Splice Enclosure 01/ Tray 01/ 03 In -> connected to -> Splice Enclosure 01/ Tray 01/ 03 Out
	Select View Trace Tab On Site Manager    ${TRACE_TAB_01}->${FIRST_PATH}        
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${nep_name_02_b}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${nep_name_02_b}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_FIBER_PATCHING}
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/02 A   
    ...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    informationDevice=02 A->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_FIBER_BACK_TO_BACK_CABLING}    
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=5    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SPLICE_ENCLOSURE_NAME}/${SPLICE_TRAY_NAME}/03 In
    ...    objectType=${TRACE_SPLICE_ENCLOSURE_IMAGE}    informationDevice=03 In->${SPLICE_TRAY_NAME}->${SPLICE_ENCLOSURE_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_SPLICE_INTERNAL_CONNECT_TYPE}
    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=6    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SPLICE_ENCLOSURE_NAME}/${SPLICE_TRAY_NAME}/03 Out 
    ...    objectType=${TRACE_SPLICE_ENCLOSURE_IMAGE}    informationDevice=03 Out->${SPLICE_TRAY_NAME}->${SPLICE_ENCLOSURE_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}

	Select View Trace Tab On Site Manager    ${TRACE_TAB_01}->${SECOND_PATH}        
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${nep_name_02_a}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${nep_name_02_a}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_FIBER_PATCHING}
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/02 B   
    ...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    informationDevice=02 B->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_FIBER_BACK_TO_BACK_CABLING}    
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=7    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SPLICE_ENCLOSURE_NAME}/${SPLICE_TRAY_NAME}/04 In
    ...    objectType=${TRACE_SPLICE_ENCLOSURE_IMAGE}    informationDevice=04 In->${SPLICE_TRAY_NAME}->${SPLICE_ENCLOSURE_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_SPLICE_INTERNAL_CONNECT_TYPE}
    Check Trace Object On Site Manager    indexObject=5    mpoType=None    objectPosition=8    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SPLICE_ENCLOSURE_NAME}/${SPLICE_TRAY_NAME}/04 Out 
    ...    objectType=${TRACE_SPLICE_ENCLOSURE_IMAGE}    informationDevice=04 Out->${SPLICE_TRAY_NAME}->${SPLICE_ENCLOSURE_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}

SM-29546_07_Verify that the Trace window with the uplink tabs are displayed with circuit: Switch in Rack -> patched 4xLC to -> Panel -> cabled to -> Faceplate
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM29546_07
    ...    AND    Delete Building     name=${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}   
    
    [Teardown]    Run Keywords    Delete Building     name=${building_name}
    ...    AND    Close Browser
    
    ${trace_tab_01} =    Set Variable    Port 1
    
    # 1. Launch and log into SM Web
    # 2. Go to "Site Manager" page
    # 3. Add: 
	# _Rack 001, LC Faceplate 01 to Room 01
	# _MPO12 Switch 01 (managed or non-managed) with some ports to Rack 001
	# _LC Panel 01 to Rack 001
	# 4. Set "Uplink Port" for Switch 01// 02
    Create Object    buildingName=${building_name}    floorName=${FLOOR_NAME}    roomName=${ROOM_NAME}    rackName=${RACK_NAME}
	Add Faceplate    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${FP_NAME}    outletType=${LC}    
    Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${PANEL_NAME}    portType=${LC}   
    Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${SWITCH_NAME}
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    name=${NEP_NAME_1}    portType=${MPO12}
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    name=${NEP_NAME_2}    portType=${MPO12}    uplinkPort=True

	# 5. Cable from Panel 01// 01-02 to Faceplate 01/ 01-02
	Open Cabling Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    01
    Create Cabling    cableFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01
    ...    cableTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${FP_NAME}    portsTo=01
    Create Cabling    cableFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/02
    ...    cableTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${FP_NAME}    portsTo=02
    Close Cabling Window
	
	# 6. Create Add Patch and complete the job from: 
	# _Switch 01// 01 (MPO12-4xLC)/ 1-1 to Panel 01// 01
	# _Switch 01// 02 (MPO12-4xLC)/ 1-1 to Panel 01// 02
	Open Patching Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    ${NEP_NAME_1}        
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}
    ...    portsFrom=${NEP_NAME_1}    portsTo=01    mpoTab=${MPO12}    mpoType=${Mpo12_4xLC}    mpoBranches=1-1    createWo=${True}    clickNext=${False}
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}
    ...    portsFrom=${NEP_NAME_2}    portsTo=02    mpoTab=${MPO12}    mpoType=${Mpo12_4xLC}    mpoBranches=1-1    createWo=${False}    clickNext=${True}
    
	# 7. Trace Switch 01// 01
	Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    ${NEP_NAME_1}

	# 8. Observe the result
	# Step 8: 
    # _The Trace window for Switch Port 01 is displayed.
    # _The circuit trace for Switch Port 01 displays: 
      # +1-1: Switch 01// 01/ 1 [A1] -> patched to -> Panel 01// 01/ 1 [1-1] -> cabled to -> Faceplate 01/ 01/ 1
      # +2-2, 3-3, 4-4: Switch 01// 01/ 1 [A1]
    Select View Trace Tab On Site Manager    ${trace_tab_01}->1-1        
    Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [A1]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_1}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_4LC_PATCHING}
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1 [1-1]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01
    ...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    informationDevice=01->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_FIBER_BACK_TO_BACK_CABLING}    
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${FP_NAME}/01
    ...    objectType=${TRACE_LC_FACEPLATE_IMAGE}    informationDevice=01->${FP_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Select View Trace Tab On Site Manager    ${trace_tab_01}->2-2        
    Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [A1]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_1}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_4LC_PATCHING}
    Select View Trace Tab On Site Manager    ${trace_tab_01}->3-3        
    Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [A1]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_1}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_4LC_PATCHING}
    Select View Trace Tab On Site Manager    ${trace_tab_01}->4-4        
    Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [A1]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_1}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_4LC_PATCHING}
 
     # _One more uplink tab is displayed with circuit: +1-1: Switch 01// 02/ 2 [A1] -> patched to -> Panel 01// 02/ 2 [1-1] -> cabled to -> Faceplate 01/ 02/ 2
     # +2-2, 3-3, 4-4: Switch 01// 02/ 2 [A1]
    Select View Trace Tab On Site Manager    ${TRACE_TAB_01}->1-1        
    Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [A1]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_1}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_4LC_PATCHING}
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1 [1-1]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01
    ...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    informationDevice=01->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_FIBER_BACK_TO_BACK_CABLING}    
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${FP_NAME}/01
    ...    objectType=${TRACE_LC_FACEPLATE_IMAGE}    informationDevice=01->${FP_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Select View Trace Tab On Site Manager    ${TRACE_TAB_01}->2-2        
    Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [A1]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_1}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_4LC_PATCHING}
    Select View Trace Tab On Site Manager    ${TRACE_TAB_01}->3-3        
    Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [A1]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_1}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_4LC_PATCHING}
    Select View Trace Tab On Site Manager    ${TRACE_TAB_01}->4-4        
    Check Trace Object On Site Manager    indexObject=2    mpoType=12    objectPosition=1 [A1]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_1}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO12_4LC_PATCHING}
    
	# 9. On the Trace window, click on the "Show/Hide Uplink Tabs" toggle button
	Click Uplink Button On Site Manager
	
	# 10. Observe the result
	Uplink Tab Should Not Be Visible On Trace Of Site Manager

SM-29546_08_Verify that the Trace window with the uplink tabs are displayed with circuit: Switch in Rack -> cabled 3xMPO to -> Panel -> patched 4xLC to -> Server
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM29546_08
    ...    AND    Delete Building     name=${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}   
    
    [Teardown]    Run Keywords    Delete Building     name=${building_name}
    ...    AND    Close Browser
    
    ${tc_trace_tab_01} =    Set Variable    Port 1
    
    # 1. Launch and log into SM Web
    # 2. Go to "Site Manager" page
	# 3. Add to Rack 001: 
	# _MPO24 Switch 01 (managed or non-managed) with some ports
	# _MPO Panel 01
	# _LC Server 01 (or Blade Server 01) with some ports
	# 4. Set "Uplink Port" for Switch 01// 02
    Create Object    buildingName=${building_name}    floorName=${FLOOR_NAME}    roomName=${ROOM_NAME}    rackName=${RACK_NAME}
    Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${SWITCH_NAME}
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    name=${NEP_NAME_1}    portType=${MPO24}
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    name=${NEP_NAME_2}    portType=${MPO24}    uplinkPort=True
    Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${PANEL_NAME}    portType=${MPO}   
    Add Device In Rack    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${SERVER_NAME}
    Add Device In Rack Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SERVER_NAME}    01    portType=${LC}    quantity=2            

	# 5. Cable from: 
	# _Switch 01// 01 (MPO24-3xMPO)/ B1 to Panel 01// 01
	# _Switch 01// 02 (MPO24-3xMPO)/ B1 to Panel 01// 02
	Open Cabling Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    ${NEP_NAME_1}
    Create Cabling    cableFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_1}
    ...    cableTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    portsTo=01    mpoTab=${MPO24}    mpoType=${Mpo24_3xMpo12}    mpoBranches=B1
    Create Cabling    cableFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_2}
    ...    cableTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    portsTo=02    mpoTab=${MPO24}    mpoType=${Mpo24_3xMpo12}    mpoBranches=B1
    Close Cabling Window
	
	# 6. Create Add Patch and complete the job from: 
	# _Panel 01// 01 (MPO12-4xLC)/ 1-1 to Server 01// 01
	# _Panel 01// 02 (MPO12-4xLC)/ 1-1 to Server 01// 02
	Open Patching Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    01        
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SERVER_NAME}
    ...    portsFrom=01    portsTo=01    mpoTab=${MPO12}    mpoType=${Mpo12_4xLC}    mpoBranches=1-1    createWo=${True}    clickNext=${False}
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SERVER_NAME}
    ...    portsFrom=02    portsTo=02    mpoTab=${MPO12}    mpoType=${Mpo12_4xLC}    mpoBranches=1-1    createWo=${False}    clickNext=${True}
    
	# 7. Trace Switch 01// 01
	Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    ${NEP_NAME_1}

	# _The Trace window for Switch Port 01 is displayed.
	# _The circuit trace for Switch Port 01 displays: 
	  # +B1: Switch 01// 01/ 1 [A1] -> cabled to -> Panel 01// 01/ 1 [A1/B1] -> cabled to -> Server 01/ 01/ 1 [1-1]
	  # +B2, B3: Switch 01// 01/ 1 [A1]
    Select View Trace Tab On Site Manager    ${tc_trace_tab_01}->B1        
    Check Trace Object On Site Manager    indexObject=2    mpoType=24    objectPosition=1 [A1]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_1}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO24_3X_MPO12_FRONT_BACK_CABLING}
    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=1 [A1/B1]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=01->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_MPO12_4LC_PATCHING}    
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=1 [1-1]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SERVER_NAME}/01
    ...    objectType=${TRACE_SERVER_FIBER_IMAGE}    informationDevice=01->${SERVER_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
   
    Select View Trace Tab On Site Manager    ${tc_trace_tab_01}->B2        
    Check Trace Object On Site Manager    indexObject=2    mpoType=24    objectPosition=1 [A1]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_1}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO24_3X_MPO12_FRONT_BACK_CABLING}
  
    Select View Trace Tab On Site Manager    ${tc_trace_tab_01}->B3        
    Check Trace Object On Site Manager    indexObject=2    mpoType=24    objectPosition=1 [A1]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_1}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO24_3X_MPO12_FRONT_BACK_CABLING}
 
	# _One more uplink tab is displayed with circuit:   
	  # +B1: Switch 01// 02/ 1 [A1] -> cabled to -> Panel 01// 02/ 1 [A1/B1] -> cabled to -> Server 01/ 02/ 2 [1-1]
	  # +B2, B3: Switch 01// 02/ 1 [A1]
    Select View Trace Tab On Site Manager    ${TRACE_TAB_01}->B1        
    Check Trace Object On Site Manager    indexObject=2    mpoType=24    objectPosition=2 [A1]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_2}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_2}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO24_3X_MPO12_FRONT_BACK_CABLING}
    Check Trace Object On Site Manager    indexObject=3    mpoType=12    objectPosition=2 [A1/B1]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/02
    ...    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}    informationDevice=02->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_MPO12_4LC_PATCHING}    
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=2 [1-1]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SERVER_NAME}/02
    ...    objectType=${TRACE_SERVER_FIBER_IMAGE}    informationDevice=02->${SERVER_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Select View Trace Tab On Site Manager    ${TRACE_TAB_01}->B2        
    Check Trace Object On Site Manager    indexObject=2    mpoType=24    objectPosition=2 [A1]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_2}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_2}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO24_3X_MPO12_FRONT_BACK_CABLING}
    Select View Trace Tab On Site Manager    ${TRACE_TAB_01}->B3        
    Check Trace Object On Site Manager    indexObject=2    mpoType=24    objectPosition=2 [A1]    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_2}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_2}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_MPO24_3X_MPO12_FRONT_BACK_CABLING}
    
	# 9. On the Trace window, click on the "Show/Hide Uplink Tabs" toggle button
	Click Uplink Button On Site Manager
	
	# 10. Observe the result
	Uplink Tab Should Not Be Visible On Trace Of Site Manager
	Close Trace Window

SM-29546_09_Verify that the Trace window with the uplink tabs are displayed with circuit: Switch in Room -> cabled to -> Panel -> patched to -> Switch in Rack
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM29546_09
    ...    AND    Delete Building     name=${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}   
    
    [Teardown]    Run Keywords    Delete Building     name=${building_name}
    ...    AND    Close Browser
    
    # 1. Launch and log into SM Web
    # 2. Go to "Site Manager" page
	# 3. Add: 
	# _Rack 001, Switch 01 (managed or non-managed) with some ports to Room 01
	# _Panel 01, Switch 02 (managed or non-managed) with some ports to Rack 001
	# 4. Set "Uplink Port" for: 
	# _Switch 01// 02
	# _Switch 02// 02
	Create Object    buildingName=${building_name}    floorName=${FLOOR_NAME}    roomName=${ROOM_NAME}    rackName=${RACK_NAME}
    Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${SWITCH_NAME}
    Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${SWITCH_NAME_2}
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}    name=${NEP_NAME_1}    portType=${RJ-45}
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}    name=${NEP_NAME_2}    portType=${RJ-45}    uplinkPort=True
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}    name=${NEP_NAME_1}    portType=${RJ-45}
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}    name=${NEP_NAME_2}    portType=${RJ-45}    uplinkPort=True
    Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${PANEL_NAME}    portType=${RJ-45}   

	# 5. Cable from Switch 01// 01-02 to Panel 01// 01-02
    Open Cabling Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}    ${NEP_NAME_1}
    Create Cabling    cableFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}/${NEP_NAME_1}
    ...    cableTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    portsTo=01
    Create Cabling    cableFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}/${NEP_NAME_2}
    ...    cableTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    portsTo=02
    Close Cabling Window

	# 6. Create Add Patch and complete the job from Panel 01// 01-02 to Switch 02// 01-02
	Open Patching Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    01        
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}
    ...    portsFrom=01    portsTo=${NEP_NAME_1}    createWo=${True}    clickNext=${False}
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}
    ...    portsFrom=02    portsTo=${NEP_NAME_2}    createWo=${False}    clickNext=${True}
	
	# 7. Trace Switch 01// 01
	Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}    ${NEP_NAME_1}
    
    # 8.Observe the result
    # * Step 8: 
	# _The Trace window for Switch 01// 01 is displayed.
	# _The circuit trace for Switch 01// 01 displays: Switch 01// 01/ 1 -> cabled to -> Panel 01// 01/ 1 -> patched to -> Switch 02/ 01/ 1
	# _One more uplink tab is displayed with circuit: 
	# Switch 01// 02/ 2 -> cabled to -> Panel 01// 02/ 2 -> patched to -> Switch 02// 02/ 2
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}/${NEP_NAME_1}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_COPPER_FRONT_TO_BACK_CABLING}
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01    
    ...    objectType=${TRACE_GENERIC_RJ_PANEL_IMAGE}    informationDevice=01->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_COPPER_PATCHING}    
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}/${NEP_NAME_1} 
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}

    Select View Trace Tab On Site Manager    ${TRACE_TAB_01}  
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}/${NEP_NAME_2}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_2}->${SWITCH_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_COPPER_FRONT_TO_BACK_CABLING}
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/02    
    ...    objectType=${TRACE_GENERIC_RJ_PANEL_IMAGE}    informationDevice=02->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_COPPER_PATCHING}    
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}/${NEP_NAME_2} 
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_2}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}

	
	# 9. On the Trace window, click on the "Show/Hide Uplink Tabs" toggle button
	Click Uplink Button On Site Manager  
	
    # 10. Observe the result
    # * Step 10: The uplink tab is disappeared in the Trace window.
    Uplink Tab Should Not Be Visible On Trace Of Site Manager

	# 11. On the Trace window, click on the "Show/Hide Uplink Tabs" toggle button
	Click Uplink Button On Site Manager
	
	# 12. Observe the result
	# * Step 12: The uplink tab is displayed again in the Trace window as step 8.
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}/${NEP_NAME_1}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_COPPER_FRONT_TO_BACK_CABLING}
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01    
    ...    objectType=${TRACE_GENERIC_RJ_PANEL_IMAGE}    informationDevice=01->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_COPPER_PATCHING}    
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}/${NEP_NAME_1} 
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}

    Select View Trace Tab On Site Manager    ${TRACE_TAB_01}  
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}/${NEP_NAME_2}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_2}->${SWITCH_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_COPPER_FRONT_TO_BACK_CABLING}
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/02    
    ...    objectType=${TRACE_GENERIC_RJ_PANEL_IMAGE}    informationDevice=02->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_COPPER_PATCHING}    
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}/${NEP_NAME_2} 
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_2}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
	Close Trace Window

	# 13. Trace Switch 02// 01
	Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}    ${NEP_NAME_1}

	# 14. Observe the result
	# _The Trace window for Switch 02// 01 is displayed.
	# _The circuit trace for Switch 02// 01 displays: Switch 02// 01/ 1 -> patched to -> Panel 01// 01/ 1 -> cabled to -> Switch 01/ 01/ 1
	# _One more uplink tab is displayed with circuit: Switch 02// 02/ 2 -> patched to -> Panel 01// 02/ 2 -> cabled to -> Switch 01// 02/ 2
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}/${NEP_NAME_1}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_COPPER_PATCHING}
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01    
    ...    objectType=${TRACE_GENERIC_RJ_PANEL_IMAGE}    informationDevice=01->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_COPPER_BACK_TO_FRONT_CABLING}    
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}/${NEP_NAME_1} 
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}

    Select View Trace Tab On Site Manager    ${TRACE_TAB_01}  
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}/${NEP_NAME_2}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_2}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_COPPER_PATCHING}
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/02    
    ...    objectType=${TRACE_GENERIC_RJ_PANEL_IMAGE}    informationDevice=02->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_COPPER_BACK_TO_FRONT_CABLING}    
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}/${NEP_NAME_2} 
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_2}->${SWITCH_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}

	# 15. On the Trace window, click on the "Show/Hide Uplink Tabs" toggle button
	Click Uplink Button On Site Manager
	
	# 16. Observe the result
	# * Step 16: The uplink tab is disappeared in the Trace window.
	Uplink Tab Should Not Be Visible On Trace Of Site Manager
	
	# 17. On the Trace window, click on the "Show/Hide Uplink Tabs" toggle button
	Click Uplink Button On Site Manager
	
	# 18. Observe the result
	# * Step 18: The uplink tab is displayed again in the Trace window as step 14.
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}/${NEP_NAME_1}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_COPPER_PATCHING}
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01    
    ...    objectType=${TRACE_GENERIC_RJ_PANEL_IMAGE}    informationDevice=01->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_COPPER_BACK_TO_FRONT_CABLING}    
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}/${NEP_NAME_1} 
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}

    Select View Trace Tab On Site Manager    ${TRACE_TAB_01}  
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}/${NEP_NAME_2}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_2}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_COPPER_PATCHING}
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/02    
    ...    objectType=${TRACE_GENERIC_RJ_PANEL_IMAGE}    informationDevice=02->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_COPPER_BACK_TO_FRONT_CABLING}    
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}/${NEP_NAME_2} 
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_2}->${SWITCH_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}

SM-29546_10_Verify that the Trace window with the uplink tabs are displayed with WO circuit: Switch in Room -> cabled to -> Panel -> patched to -> Switch in Rack
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM29546_10
    ...    AND    Delete Building     name=${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}   
    
    [Teardown]    Run Keywords    Delete Building     name=${building_name}
    ...    AND    Close Browser
    
    ${trace_tab_02} =    Set Variable    Port 1
    
    # 1. Launch and log into SM Web
    # 2. Go to "Site Manager" page
    # 3. Add: 
	# _Rack 001, Switch 01 (managed or non-managed) with some ports to Room 01
	# _Panel 01, Switch 02 (managed or non-managed) with some ports to Rack 001
	# 4. Set "Uplink Port" for: 
	# _Switch 01// 02
	# _Switch 02// 02
	Create Object    buildingName=${building_name}    floorName=${FLOOR_NAME}    roomName=${ROOM_NAME}    rackName=${RACK_NAME}
    Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${SWITCH_NAME}
    Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${SWITCH_NAME_2}
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}    name=${NEP_NAME_1}    portType=${RJ-45}
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}    name=${NEP_NAME_2}    portType=${RJ-45}    uplinkPort=True
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}    name=${NEP_NAME_1}    portType=${RJ-45}
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}    name=${NEP_NAME_2}    portType=${RJ-45}    uplinkPort=True
    Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${PANEL_NAME}    portType=${RJ-45}   

	# 5. Cable from Switch 01// 01-02 to Panel 01// 01-02
    Open Cabling Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}    ${NEP_NAME_1}
    Create Cabling    cableFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}/${NEP_NAME_1}
    ...    cableTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    portsTo=01
    Create Cabling    cableFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}/${NEP_NAME_2}
    ...    cableTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    portsTo=02
    Close Cabling Window

	# 6. Create Add Patch and DO NOT complete the job from Panel 01// 01-02 to Switch 02// 01-02
	Open Patching Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    01        
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}
    ...    portsFrom=01    portsTo=${NEP_NAME_1}    createWo=${True}    clickNext=${False}
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}
    ...    portsFrom=02    portsTo=${NEP_NAME_2}    createWo=${True}   clickNext=${True}
    Create Work Order        

	# 7. Trace Switch 02// 01
	Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}    ${NEP_NAME_1}
    
    # 8. On the Trace window, notice the uplink tab also displays
	# 9. Observe the circuit in the first tab for Switch 02// 01 and the uplink tab for Switch 02// 02
	# * Step 9: The Trace window for Switch 02// 01 is displayed with: 
	# _First tab for Switch 02// 01 in Current View: Switch 02// 01
	# _Uplink tab for Switch 02// 02 in Current View: Switch 02// 02
	Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}/${NEP_NAME_1}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Select View Trace Tab On Site Manager    ${TRACE_TAB_01} 
	Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}/${NEP_NAME_2}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_2}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}

	# 10. Select "Scheduled" view
	Select View Type On Trace    Scheduled        

	# 11. Observe the circuit in the first tab for Switch 02// 01 and the uplink tab for Switch 02// 02
	# _First tab for Switch 02// 01 in Scheduled View: Switch 02// 01/ 1 -> patched to -> Panel 01// 01/ 1 -> cabled to -> Switch 01// 01/ 1
    # _Uplink tab for Switch 02// 02 in Scheduled View: Switch 02// 02/ 2 -> patched to -> Panel 01// 02/ 2 -> cabled to -> Switch 01// 02/ 2
	Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}/${NEP_NAME_2}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    scheduleIcon=${TRACE_SCHEDULED_IMAGE}    informationDevice=${NEP_NAME_2}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_COPPER_PATCHING}
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/02
    ...    objectType=${TRACE_GENERIC_RJ_PANEL_IMAGE}    informationDevice=02->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_COPPER_BACK_TO_FRONT_CABLING}    
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}/${NEP_NAME_2} 
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_2}->${SWITCH_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}

	Select View Trace Tab On Site Manager    ${trace_tab_02} 
	Select View Type On Trace    Scheduled

	Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}/${NEP_NAME_1}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    scheduleIcon=${TRACE_SCHEDULED_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_COPPER_PATCHING}
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01    
    ...    objectType=${TRACE_GENERIC_RJ_PANEL_IMAGE}    informationDevice=01->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_COPPER_BACK_TO_FRONT_CABLING}    
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}/${NEP_NAME_1} 
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}

	Close Trace Window
	
	# 12. Trace Switch 01// 01
	# 13. On the Trace window, notice the uplink tab also displays
    Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}    ${NEP_NAME_1}
	
	# 14. Observe the circuit in the first tab for Switch 01// 01 and the uplink tab for Switch 01// 02
	# * Step 14: The Trace window for Switch 01// 01 is displayed with: 
	# _First tab for Switch 01// 01 in Current View: Switch 01// 01/ 1 -> cabled to -> Panel 01// 01/ 1
	# _Uplink tab for Switch 01// 02 in Current View: Switch 01// 02/ 2 -> cabled to -> Panel 01// 02/ 2
	Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}/${NEP_NAME_1}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_COPPER_FRONT_TO_BACK_CABLING}
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01
    ...    objectType=${TRACE_GENERIC_RJ_PANEL_IMAGE}    informationDevice=01->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    
    Select View Trace Tab On Site Manager    ${TRACE_TAB_01}
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}/${NEP_NAME_2}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_2}->${SWITCH_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_COPPER_FRONT_TO_BACK_CABLING}
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/02
    ...    objectType=${TRACE_GENERIC_RJ_PANEL_IMAGE}    informationDevice=02->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}

	# 15. Select "Scheduled" view
	Select View Type On Trace    Scheduled
	    
	# 16. Observe the circuit in the first tab for Switch 01// 01 and the uplink tab for Switch 01// 02
	Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}/${NEP_NAME_2}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_2}->${SWITCH_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_COPPER_FRONT_TO_BACK_CABLING}
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/02
    ...    objectType=${TRACE_GENERIC_RJ_PANEL_IMAGE}    informationDevice=02->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_COPPER_PATCHING}    scheduleIcon=${TRACE_SCHEDULED_IMAGE}    
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}/${NEP_NAME_2} 
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_2}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}

	Select View Trace Tab On Site Manager    ${trace_tab_02}
	Select View Type On Trace    Scheduled
	
	Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}/${NEP_NAME_1}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_COPPER_FRONT_TO_BACK_CABLING}
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01
    ...    objectType=${TRACE_GENERIC_RJ_PANEL_IMAGE}    informationDevice=01->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_COPPER_PATCHING}    scheduleIcon=${TRACE_SCHEDULED_IMAGE}    
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}/${NEP_NAME_1} 
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}

SM-29546_12_Verify that the Trace window with the uplink tabs are displayed in Circuit History with circuit: Faceplate -> cabled to -> Panel -> patched to -> Switch in Rack
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM29546_12
    ...    AND    Delete Building     name=${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}   
    
    [Teardown]    Run Keywords    Delete Building     name=${building_name}
    ...    AND    Close Browser
    
    # 1. Launch and log into SM Web
    # 2. Go to "Site Manager" page
	# 3. Add: 
	# _Rack 001, Faceplate 01 (RJ-45, LC) to Room 01
	# _Panel 01 (RJ-45, LC), Switch 01 (managed or non-managed) with some ports (RJ-45, LC) to Rack 001
	# 4. Set "Uplink Port" for Switch 01// 02
	Create Object    buildingName=${building_name}    floorName=${FLOOR_NAME}    roomName=${ROOM_NAME}    rackName=${RACK_NAME}
	Add Faceplate    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${FP_NAME}    outletType=${RJ-45}    
    Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${PANEL_NAME}    portType=${RJ-45}   
    Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${SWITCH_NAME}
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    name=${NEP_NAME_1}    portType=${RJ-45}
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    name=${NEP_NAME_2}    portType=${RJ-45}    uplinkPort=True

    # 5. Cable from Panel 01// 01-02 to Faceplate 01/ 01-02
	Open Cabling Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    01
    Create Cabling    cableFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01
    ...    cableTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${FP_NAME}    portsTo=01
    Create Cabling    cableFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/02
    ...    cableTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${FP_NAME}    portsTo=02
    Close Cabling Window	
	
    # 6. Create Add Patch and complete the job from Panel 01// 01-02 to Switch 01// 01-02
	Open Patching Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    01        
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}
    ...    portsFrom=01    portsTo=${NEP_NAME_1}    createWo=${True}    clickNext=${False}
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}
    ...    portsFrom=02    portsTo=${NEP_NAME_2}    createWo=${False}    clickNext=${True}
    
	# 7. Trace Switch 01// 01
    Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    ${NEP_NAME_1}
    # 8. Notice: 
	# _The circuit trace for Switch 01// 01 displays: Switch 01// 01/ 1 -> cabled to -> Panel 01// 01/ 1 -> patched to -> Switch 02/ 01/ 1
	# _One more uplink tab is displayed with circuit: Switch 01// 02/ 2 -> cabled to -> Panel 01// 02/ 2 -> patched to -> Switch 02/ 02/ 2
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_1}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_COPPER_PATCHING}    
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01    
    ...    objectType=${TRACE_GENERIC_RJ_PANEL_IMAGE}    informationDevice=01->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_COPPER_BACK_TO_BACK_CABLING}   
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${FP_NAME}/01    
    ...    objectType=${TRACE_RJ_FACEPLATE_IMAGE}    informationDevice=01->${FP_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}

	Select View Trace Tab On Site Manager    ${TRACE_TAB_01}
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_2}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_2}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_COPPER_PATCHING}    
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/02
    ...    objectType=${TRACE_GENERIC_RJ_PANEL_IMAGE}    informationDevice=02->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_COPPER_BACK_TO_BACK_CABLING}   
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${FP_NAME}/02  
    ...    objectType=${TRACE_RJ_FACEPLATE_IMAGE}    informationDevice=02->${FP_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    
    # 9. Close the Trace window
    Close Trace Window
    
	# 10. Select this Switch 01// 01 and open its Circuit History window
	Open Circuit History    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    ${NEP_NAME_1}        

	# 11. Observe the result
    Check Trace Object On Circuit History    indexObject=2    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_1}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_COPPER_PATCHING}    
    Check Trace Object On Circuit History    indexObject=3    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01    
    ...    objectType=${TRACE_GENERIC_RJ_PANEL_IMAGE}    informationDevice=01->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_COPPER_BACK_TO_BACK_CABLING}   
    Check Trace Object On Circuit History    indexObject=4    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${FP_NAME}/01    
    ...    objectType=${TRACE_RJ_FACEPLATE_IMAGE}    informationDevice=01->${FP_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}

    Close Circuit History Window
     
    ###LC###
    Delete Tree Node On Site Manager     ${SITE_NODE}/${building_name} 

    Create Object    buildingName=${building_name}    floorName=${FLOOR_NAME}    roomName=${ROOM_NAME}    rackName=${RACK_NAME}
	Add Faceplate    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${FP_NAME}    outletType=${LC}    
    Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${PANEL_NAME}    portType=${LC}   
    Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${SWITCH_NAME}
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    name=${NEP_NAME_1}    portType=${LC}
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    name=${NEP_NAME_2}    portType=${LC}    uplinkPort=True

    # 5. Cable from Panel 01// 01-02 to Faceplate 01/ 01-02
	Open Cabling Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    01
    Create Cabling    cableFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01
    ...    cableTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${FP_NAME}    portsTo=01
    Create Cabling    cableFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/02
    ...    cableTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${FP_NAME}    portsTo=02
    Close Cabling Window	
	
    # 6. Create Add Patch and complete the job from Panel 01// 01-02 to Switch 01// 01-02
	Open Patching Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    01        
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}
    ...    portsFrom=01    portsTo=${NEP_NAME_1}    createWo=${True}    clickNext=${False}
    Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}
    ...    portsFrom=02    portsTo=${NEP_NAME_2}    createWo=${False}    clickNext=${True}
    
	# 7. Trace Switch 01// 01
    Open Trace Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    ${NEP_NAME_1}
    # 8. Notice: 
	# _The circuit trace for Switch 01// 01 displays: Switch 01// 01/ 1 -> cabled to -> Panel 01// 01/ 1 -> patched to -> Switch 02/ 01/ 1
	# _One more uplink tab is displayed with circuit: Switch 01// 02/ 2 -> cabled to -> Panel 01// 02/ 2 -> patched to -> Switch 02/ 02/ 2
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_1}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_FIBER_PATCHING}    
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01    
    ...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    informationDevice=01->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_FIBER_BACK_TO_BACK_CABLING}   
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${FP_NAME}/01    
    ...    objectType=${TRACE_LC_FACEPLATE_IMAGE}    informationDevice=01->${FP_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}

	Select View Trace Tab On Site Manager    ${TRACE_TAB_01}
    Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_2}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_2}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_FIBER_PATCHING}    
    Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/02
    ...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    informationDevice=02->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_FIBER_BACK_TO_BACK_CABLING}   
    Check Trace Object On Site Manager    indexObject=4    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${FP_NAME}/02  
    ...    objectType=${TRACE_LC_FACEPLATE_IMAGE}    informationDevice=02->${FP_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    
    # 9. Close the Trace window
    Close Trace Window
    
	# 10. Select this Switch 01// 01 and open its Circuit History window
	Open Circuit History    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}    ${NEP_NAME_1}        

	# 11. Observe the result
    Check Trace Object On Circuit History    indexObject=2    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME}/${NEP_NAME_1}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_FIBER_PATCHING}    
    Check Trace Object On Circuit History    indexObject=3    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01    
    ...    objectType=${TRACE_GENERIC_LC_PANEL_IMAGE}    informationDevice=01->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}     connectionType=${TRACE_FIBER_BACK_TO_BACK_CABLING}   
    Check Trace Object On Circuit History    indexObject=4    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${FP_NAME}/01    
    ...    objectType=${TRACE_LC_FACEPLATE_IMAGE}    informationDevice=01->${FP_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}

    Uplink Tab Should Not Be Visible On Trace Of Site Manager
    
    Close Circuit History Window
    
SM-29546_13_Verify that the Uplink tabs are displayed correctly in the Cabling/Patching window
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    BD_SM29546_13
    ...    AND    Delete Building     name=${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}   
    
    [Teardown]    Run Keywords    Delete Building     name=${building_name}
    ...    AND    Close Browser
    
    ${trace_tab_02} =    Set Variable    Port 1
    
    # 1. Launch and log into SM Web
    # 2. Go to "Site Manager" page
    # 3. Add: 
	# _Rack 001, Switch 01 (managed or non-managed) with some ports to Room 01
	# _Panel 01, Switch 02 (managed or non-managed) with some ports to Rack 001
	# 4. Set "Uplink Port" for: 
	# _Switch 01// 02
	# _Switch 02// 02
	Create Object    buildingName=${building_name}    floorName=${FLOOR_NAME}    roomName=${ROOM_NAME}    rackName=${RACK_NAME}
    Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${SWITCH_NAME}
    Add Network Equipment    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${SWITCH_NAME_2}
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}    name=${NEP_NAME_1}    portType=${RJ-45}
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}    name=${NEP_NAME_2}    portType=${RJ-45}    uplinkPort=True
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}    name=${NEP_NAME_1}    portType=${RJ-45}
    Add Network Equipment Port    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}    name=${NEP_NAME_2}    portType=${RJ-45}    uplinkPort=True
    Add Generic Panel    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}    ${PANEL_NAME}    portType=${RJ-45}   

    # 5. Open the Cabling window
    # 6. Select Switch 01// 01 or Switch 02// 01 and click on Trace button
    Open Cabling Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}    ${NEP_NAME_1}        
    Open Trace Window On Cabling
    
    # 7. Observe the result
    # * Step 7: 
	# _The Trace window for the selected Switch Port is displayed.
	# _The circuit for Switch Port displays: Switch 01/ 01/ 1 (or Switch 02/ 01/ 1)
	# _There is new toggle button "Show/Hide Uplink Tabs" in the Trace window. User can click on this button to show or hide the uplink tabs.
	Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}/${NEP_NAME_1}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    
    Uplink Button Should Be Visible On Trace Of Site Manager
    
    # User can click on this button to show or hide the uplink tabs.
    Click Uplink Button On Site Manager
    Uplink Tab Should Not Be Visible On Trace Of Site Manager
    Click Uplink Button On Site Manager
    Uplink Tab Should Be Visible On Trace Of Site Manager
    Close Trace Window
    
    # 8. On the Cabling window, cable from Panel 01// 01-02 to Switch 01// 01-02
    Create Cabling    cableFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01
    ...    cableTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}    portsTo=${NEP_NAME_1}
    Create Cabling    cableFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/02
    ...    cableTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}    portsTo=${NEP_NAME_2}

	# 9. Select Switch 01// 01 in the From/To pane and click on Trace button
	Open Trace Window On Cabling    From    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}/${NEP_NAME_1}    
	
	# 10. Observe the result
	# _The circuit trace for the selected Switch 01// 01 is displayed: Switch 01// 01/ 1 -> cabled to -> Panel 01// 01/ 1
    # _One more uplink tab is displayed with circuit: Switch 01// 02/ 2 -> cabled to -> Panel 01// 02/ 2
	Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}/${NEP_NAME_1}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_COPPER_FRONT_TO_BACK_CABLING}    
	Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=1    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/01   
    ...    objectType=${TRACE_GENERIC_RJ_PANEL_IMAGE}    informationDevice=01->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Select View Trace Tab On Site Manager    ${TRACE_TAB_01}
	Check Trace Object On Site Manager    indexObject=2    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SWITCH_NAME}/${NEP_NAME_2}    
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_2}->${SWITCH_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_COPPER_FRONT_TO_BACK_CABLING}    
	Check Trace Object On Site Manager    indexObject=3    mpoType=None    objectPosition=2    objectPath=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}/02    
    ...    objectType=${TRACE_GENERIC_RJ_PANEL_IMAGE}    informationDevice=02->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Trace Window	

	# 11. Close the Cabling window
	Close Cabling Window

	# 12. Open the Patching window
	# 13. Select Switch 02// 01 and observe the result in the Circuit Trace tab
	# * Step 13: 
	# _The circuit trace for the selected Switch 02// 01 is displayed: Switch 02// 01/ 1
	# _One more uplink tab is displayed with circuit: Switch 02// 02/ 2
    Open Patching Window    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}    ${NEP_NAME_1}        	
    
    Check Trace Object On Patching    indexObject=2    mpoType=None    objectPosition=1    objectPath=None
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    
    Select View Trace Tab On Patching    ${TRACE_TAB_01}
    
    Check Trace Object On Patching    indexObject=2    mpoType=None    objectPosition=2    objectPath=None
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_2}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}

	# 14. Patch from Panel 01// 01 to Switch 02// 01
	Create Patching    patchFrom=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${SWITCH_NAME_2}    patchTo=${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${POSITION_RACK_NAME}/${PANEL_NAME}
    ...    portsFrom=${NEP_NAME_1}    portsTo=01    createWo=${True}    clickNext=${False}

    # 15. Observe the result in the Circuit Trace tab
    # * Step 15: 
	# _The circuit trace for the selected Switch 02// 01 is displayed: Switch 02// 01/ 1 -> patched to -> Panel 01// 01/ 1 -> cabled to -> Switch 01// 01/ 1
	# _One more uplink tab is displayed with circuit: Switch 02// 02/ 2
    Check Trace Object On Patching    indexObject=2    mpoType=None    objectPosition=1    objectPath=None
    ...    objectType=${TRACE_SWITCH_IMAGE}    scheduleIcon=${TRACE_SCHEDULED_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_COPPER_PATCHING}   
    Check Trace Object On Patching    indexObject=3    mpoType=None    objectPosition=1    objectPath=None
    ...    objectType=${TRACE_GENERIC_RJ_PANEL_IMAGE}    informationDevice=01->${PANEL_NAME}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}    connectionType=${TRACE_COPPER_BACK_TO_FRONT_CABLING}
    Check Trace Object On Patching    indexObject=4    mpoType=None    objectPosition=1    objectPath=None
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_1}->${SWITCH_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    
    Select View Trace Tab On Patching    ${TRACE_TAB_01}
        Check Trace Object On Patching    indexObject=2    mpoType=None    objectPosition=2    objectPath=None
    ...    objectType=${TRACE_SWITCH_IMAGE}    informationDevice=${NEP_NAME_2}->${SWITCH_NAME_2}->${POSITION_RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    Close Patching Window
    
    