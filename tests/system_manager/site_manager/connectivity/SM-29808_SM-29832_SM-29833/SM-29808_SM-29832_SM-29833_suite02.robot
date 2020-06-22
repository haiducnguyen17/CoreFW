*** Settings ***
Resource    ../../../../../resources/constants.robot       
Resource    ../../../../../resources/icons_constants.robot  

Library    ../../../../../py_sources/logigear/setup.py     
Library    ../../../../../py_sources/logigear/api/BuildingApi.py    ${USERNAME}    ${PASSWORD}   
Library    ../../../../../py_sources/logigear/page_objects/system_manager/login/LoginPage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/zone_header/ZoneHeaderPage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/SiteManagerPage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/cabling/CablingPage${PLATFORM}.py       
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/patching/PatchingPage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/tools/database_tools/RestoreDatabasePage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/work_orders/create_work_order/CreateWorkOrderPage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/work_orders/work_order_queue/WorkOrderQueuePage${PLATFORM}.py   
   
Suite Setup    Run Keywords    Open SM Login Page
...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
...    AND    Restore Database    ${RESTORED_FILE_NAME}     ${DIR_FILE_BK}
...    AND    Close Browser      

Suite Teardown    Run Keyword    Delete Building    name=${BUILDING_NAME}

Default Tags    Connectivity
Force Tags    SM-29808_SM-29832_SM-29833

*** Variables ***
${FLOOR_NAME_1}    Floor 01
${FLOOR_NAME_2}    Floor 02
${FLOOR_NAME_3}    Floor 03 
${ROOM_NAME}    Room 01
${RACK_GROUP_NAME}    Rack Group 01
${RACK_NAME}    Rack 001
${SWITCH_NAME_1}    Switch 01
${SWITCH_NAME_2}    Switch 02
${SWITCH_NAME_3}    Blade 1 BX630 F1R5 cabina 1
${SWITCH_NAME_4}    Blade 2 BX630 F1R5 cabina 1
${SERVER_NAME_1}    Server 01
${SERVER_NAME_2}    Server 02
${CARD_NAME_1}    Card 01
${CARD_NAME_2}    Card 02
${FACEPLATE_NAME}    Faceplate 01
${PANEL_NAME_1}    Panel 01
${PANEL_NAME_2}    Panel 02
${PANEL_NAME_3}    Panel 03
${GBIC_SLOT_1}    GBIC Slot 01
${TRAY_NAME}    Tray 01
${BLADE_SERVER_NAME}    Blade Server 01
${ENCLOSURE_NAME}    Enclosure 01
${ZONE}    1
${POSITION}    1
${BUILDING_NAME}    Building_SM_29975_30_31_32
${RESTORED_FILE_NAME}    SM9.1_TC_SM_29975_30_31_32.bak
${WORK_ORDER_1}    WO_SM_29832_30_01
${WORK_ORDER_2}    WO_SM_29832_30_02

*** Test Cases ***
SM-29808_SM-29832_30_Verify that after converting DB, the service is propagated and trace correctly in customer circuit: LC Switch -> patched 6xLC to -> MPO12 Panel -> cabled to -> MPO12 Panel -> patched 6xLC to -> LC Server
    [Setup]    Run Keywords    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
            
    [Teardown]    Close Browser
        
    ${ip_address}    Set Variable    IP: 10.5.1.108
    ${tree_node_rack_1}    Set Variable    ${SITE_NODE}/${BUILDING_NAME}/${FLOOR_NAME_1}/${ROOM_NAME}/${ZONE}:${POSITION} ${RACK_NAME}        
    ${tree_node_panel_1}    Set Variable    ${tree_node_rack_1}/${PANEL_NAME_1}
    ${tree_node_panel_2}    Set Variable    ${tree_node_rack_1}/${PANEL_NAME_2}
    ${tree_node_server_1_card_1}    Set Variable    ${tree_node_rack_1}/${SERVER_NAME_1}/${CARD_NAME_1}  
    ${tree_node_switch_1}    Set Variable    ${tree_node_rack_1}/${SWITCH_NAME_3}
    ${device_information_rack_1}    Set Variable    ${ZONE}:${POSITION} ${RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_1}->${BUILDING_NAME}->${SITE_NODE}    
    ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}       
    ${object_position_list}    Create List    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}
    ${pair_list_1}	Create List    ${A1-2}    ${A3-4}    ${A5-6}    ${A7-8}    ${A9-10}    ${A11-12}
    ${pair_list_2}	Create List    ${Pair 1}    ${Pair 2}    ${Pair 3}    ${Pair 4}    ${Pair 5}    ${Pair 6}
    ${vlan_list}	Create List    214    214    214    91    3001    92

    # 1. Prepare two test machines:
	# _Machine 1: Install the previous SM Build (e.g. SM9.1) which has not supported new 6xLC assembly in purple yet
	# _Machine 2: Install the latest SM Build
	# 2. Launch and log into SM Web of machine 1
	# 3. Go to "Site Manager" page
	# 4. Add to Rack 001:
	# _LC Switch 01
	# _MPO Panel 01
	# _MPO Panel 02
	# _LC Server 01
	# 5. Set Data service for Switch 01// 01-06 directly
	# 6. Cable from Panel 01// 01 (MPO12-MPO12) to Panel 02// 01
	# 7. Create the Add Patch job and complete the job from:
	# _Panel 01// 01 (MPO12-6xLC)/ A1-2 -> A11-12 to Switch 01// 01-06
	# _Panel 02// 01 (MPO12-6xLC)/ A1-2 -> A11-12 to Server 01// 01-06
	# 8. Observe the port icons, the port statuses, the propagated services and trace horizontal and vertical them
	# 9. Backup this DB then restore this DB to machine 2 successfully
	# 10. Launch and log into SM Web of machine 2	
	# 11. Go to "Site Manager" page
	# 12. Observe the port icons, the port statuses, the propagated services and trace horizontal and vertical them
	# _Port icons for:
	#     +Switch 01// 01-06: patched icon (including purple icon)
	#     +Panel 01-02// 01: cabled and patched icons
	#     +Server 01// 01-06: patched icon
   	# _Port statuses for Switch 01// 01-06, Panel 01-02// 01 and Server 01// 01-06: In Use
	# _Data service is propagated on the Properties pane/window of Panel 01-02// 01 and Server 01// 01-06.     
	# _The circuit trace displays:
	# +Current View: Switch 01// 01-06/ 1 [A1-2] - 6 [A11-12] -> patched to -> Panel 01// 01/ 1 [A1] -> cabled to -> Panel 02// 01/ 1 [A1] -> patched to -> Server 01// 06-01/ 6 [A11-12] - 1 [A1-2] 

	:FOR    ${i}    IN RANGE    0    len(${port_list}) 
	\    ${i1}=    Evaluate    len(${port_list})-1-${i}    
	\    Open Trace Window    ${tree_node_switch_1}    ${port_list}[${i}]	    
	\    Check Total Trace On Site Manager    5    	
	\    Check Trace Object On Site Manager    indexObject=1    objectPosition=since:2020-03-23    objectPath=${Config}: /${VLAN}: ${vlan_list}[${i}]/${Service}: ${Data}    objectType=${Trace Service Object}
	...    connectionType=${Trace Assign}    informationDevice=${Service}:->${Data}->${VLAN}: ${vlan_list}[${i}]->${Config}:
	\    Check Trace Object On Site Manager    indexObject=2    objectPosition=${object_position_list}[${i}] [${pair_list_1}[${i}]]    objectPath=${tree_node_switch_1}/${port_list}[${i}]    objectType=${Trace Managed Switch}
	...    portIcon=${PortNEFDServiceInUse}    connectionType=${TRACE_LC_6X_MPO12_PATCHING}    informationDevice=${port_list}[${i}]->${SWITCH_NAME_3}->${ip_address}->${device_information_rack_1}
	\    Check Trace Object On Site Manager    indexObject=3    objectPosition=${1} [${A1}]    objectPath=${tree_node_panel_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
	...    mpoType=${12}    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
	...    informationDevice=${01}->${PANEL_NAME_1}->${device_information_rack_1}	
	\    Check Trace Object On Site Manager    indexObject=4    objectPosition=${1} [${A1}]    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
	...    mpoType=${12}    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_6X_LC_PATCHING}
	...    informationDevice=${01}->${PANEL_NAME_2}->${device_information_rack_1}
	\    Check Trace Object On Site Manager    indexObject=5    objectPosition=${object_position_list}[${i1}] [${pair_list_1}[${i1}]]    objectPath=${tree_node_server_1_card_1}/${port_list}[${i1}]    objectType=${Trace ServerCard}
	...    portIcon=${PortFDUncabledInUse}    informationDevice=${port_list}[${i1}]->${CARD_NAME_1}->${SERVER_NAME_1}->${device_information_rack_1}
	\    Close Trace Window
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortNEFDServiceInUse}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${In Use}    ${i+1}
	
    Open Trace Window    ${tree_node_panel_1}    ${01}
    :FOR    ${i}    IN RANGE    0    len(${port_list}) 
	\    ${i1}=    Evaluate    len(${port_list})-1-${i}    
	\    Select View Trace Tab On Site Manager    ${pair_list_1}[${i}]	    
	\    Check Total Trace On Site Manager    5    	
	\    Check Trace Object On Site Manager    indexObject=1    objectPosition=since:2020-03-23    objectPath=${Config}: /${VLAN}: ${vlan_list}[${i}]/${Service}: ${Data}    objectType=${Trace Service Object}
	...    connectionType=${Trace Assign}    informationDevice=${Service}:->${Data}->${VLAN}: ${vlan_list}[${i}]->${Config}:
	\    Check Trace Object On Site Manager    indexObject=2    objectPosition=${object_position_list}[${i}] [${pair_list_1}[${i}]]    objectPath=${tree_node_switch_1}/${port_list}[${i}]    objectType=${Trace Managed Switch}
	...    portIcon=${PortNEFDServiceInUse}    connectionType=${TRACE_LC_6X_MPO12_PATCHING}    informationDevice=${port_list}[${i}]->${SWITCH_NAME_3}->${ip_address}->${device_information_rack_1}
	\    Check Trace Object On Site Manager    indexObject=3    objectPosition=${1} [${A1}]    objectPath=${tree_node_panel_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
	...    mpoType=${12}    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
	...    informationDevice=${01}->${PANEL_NAME_1}->${device_information_rack_1}	
	\    Check Trace Object On Site Manager    indexObject=4    objectPosition=${1} [${A1}]    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
	...    mpoType=${12}    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_6X_LC_PATCHING}
	...    informationDevice=${01}->${PANEL_NAME_2}->${device_information_rack_1}
	\    Check Trace Object On Site Manager    indexObject=5    objectPosition=${object_position_list}[${i1}] [${pair_list_1}[${i1}]]    objectPath=${tree_node_server_1_card_1}/${port_list}[${i1}]    objectType=${Trace ServerCard}
	...    portIcon=${PortFDUncabledInUse}    informationDevice=${port_list}[${i1}]->${CARD_NAME_1}->${SERVER_NAME_1}->${device_information_rack_1}
	Close Trace Window   
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOPanelCabledInUse}   
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}    1
    Check Object Properties On Properties Pane    ${Service}    ${Data}
	
	Open Trace Window    ${tree_node_panel_2}    ${01}
    :FOR    ${i}    IN RANGE    0    len(${port_list}) 
	\    ${i1}=    Evaluate    len(${port_list})-1-${i}    
	\    Select View Trace Tab On Site Manager    ${pair_list_1}[${i}]	    
	\    Check Total Trace On Site Manager    5    	
	\    Check Trace Object On Site Manager    indexObject=1    objectPosition=since:2020-03-23    objectPath=${Config}: /${VLAN}: ${vlan_list}[${i1}]/${Service}: ${Data}    objectType=${Trace Service Object}
	...    connectionType=${Trace Assign}    informationDevice=${Service}:->${Data}->${VLAN}: ${vlan_list}[${i1}]->${Config}:
	\    Check Trace Object On Site Manager    indexObject=2    objectPosition=${object_position_list}[${i1}] [${pair_list_1}[${i1}]]    objectPath=${tree_node_switch_1}/${port_list}[${i1}]    objectType=${Trace Managed Switch}
	...    portIcon=${PortNEFDServiceInUse}    connectionType=${TRACE_LC_6X_MPO12_PATCHING}    informationDevice=${port_list}[${i1}]->${SWITCH_NAME_3}->${ip_address}->${device_information_rack_1}
	\    Check Trace Object On Site Manager    indexObject=3    objectPosition=${1} [${A1}]    objectPath=${tree_node_panel_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
	...    mpoType=${12}    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
	...    informationDevice=${01}->${PANEL_NAME_1}->${device_information_rack_1}	
	\    Check Trace Object On Site Manager    indexObject=4    objectPosition=${1} [${A1}]    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
	...    mpoType=${12}    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_6X_LC_PATCHING}
	...    informationDevice=${01}->${PANEL_NAME_2}->${device_information_rack_1}
	\    Check Trace Object On Site Manager    indexObject=5    objectPosition=${object_position_list}[${i}] [${pair_list_1}[${i}]]    objectPath=${tree_node_server_1_card_1}/${port_list}[${i}]    objectType=${Trace ServerCard}
	...    portIcon=${PortFDUncabledInUse}    informationDevice=${port_list}[${i}]->${CARD_NAME_1}->${SERVER_NAME_1}->${device_information_rack_1}
	Close Trace Window
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOPanelCabledInUse}    
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}    1
	Check Object Properties On Properties Pane    ${Service}    ${Data}

    :FOR    ${i}    IN RANGE    0    len(${port_list}) 
	\    ${i1}=    Evaluate    len(${port_list})-1-${i}    
	\    Open Trace Window    ${tree_node_server_1_card_1}    ${port_list}[${i}]	    
	\    Check Total Trace On Site Manager    5    	
	\    Check Trace Object On Site Manager    indexObject=1    objectPosition=since:2020-03-23    objectPath=${Config}: /${VLAN}: ${vlan_list}[${i1}]/${Service}: ${Data}    objectType=${Trace Service Object}
	...    connectionType=${Trace Assign}    informationDevice=${Service}:->${Data}->${VLAN}: ${vlan_list}[${i1}]->${Config}:
	\    Check Trace Object On Site Manager    indexObject=2    objectPosition=${object_position_list}[${i1}] [${pair_list_1}[${i1}]]    objectPath=${tree_node_switch_1}/${port_list}[${i1}]    objectType=${Trace Managed Switch}
	...    portIcon=${PortNEFDServiceInUse}    connectionType=${TRACE_LC_6X_MPO12_PATCHING}    informationDevice=${port_list}[${i1}]->${SWITCH_NAME_3}->${ip_address}->${device_information_rack_1}
	\    Check Trace Object On Site Manager    indexObject=3    objectPosition=${1} [${A1}]    objectPath=${tree_node_panel_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
	...    mpoType=${12}    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
	...    informationDevice=${01}->${PANEL_NAME_1}->${device_information_rack_1}	
	\    Check Trace Object On Site Manager    indexObject=4    objectPosition=${1} [${A1}]    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
	...    mpoType=${12}    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_6X_LC_PATCHING}
	...    informationDevice=${01}->${PANEL_NAME_2}->${device_information_rack_1}
	\    Check Trace Object On Site Manager    indexObject=5    objectPosition=${object_position_list}[${i}] [${pair_list_1}[${i}]]    objectPath=${tree_node_server_1_card_1}/${port_list}[${i}]    objectType=${Trace ServerCard}
	...    portIcon=${PortFDUncabledInUse}    informationDevice=${port_list}[${i}]->${CARD_NAME_1}->${SERVER_NAME_1}->${device_information_rack_1}
	\    Close Trace Window
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortFDUncabledInUse}    
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${In Use}    ${i+1}
	\    Check Object Properties On Properties Pane    ${Current Service}    ${Data}

	# 13. Create the Remove Patch job and complete the job from:
	# _Panel 01// 01 (MPO12-6xLC)/ A1-2 -> A11-12 to Switch 01// 01-06
	# _Panel 02// 01 (MPO12-6xLC)/ A1-2 -> A11-12 to Server 01// 01-06
    Open Patching Window    ${tree_node_panel_1}    ${01}
    Create Patching    patchFrom=${tree_node_panel_1}    patchTo=${tree_node_switch_1}    typeConnect=Disconnect
    ...    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC}    mpoBranches=${A1-2},${A3-4},${A5-6},${A7-8},${A9-10},${A11-12}
    ...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05},${06}    createWo=${True}    clickNext=${True}	
    Create Work Order    ${WORK_ORDER_1}       
    Wait For Property On Properties Pane    ${Port Status}    ${Available - Pending}        

    Open Patching Window    ${tree_node_panel_2}    ${01}
    Create Patching    patchFrom=${tree_node_panel_2}    patchTo=${tree_node_server_1_card_1}    typeConnect=Disconnect
    ...    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC}    mpoBranches=${A1-2},${A3-4},${A5-6},${A7-8},${A9-10},${A11-12}
    ...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05},${06}    createWo=${True}    clickNext=${True}	
    Create Work Order    ${WORK_ORDER_2}
    Wait For Property On Properties Pane    ${Port Status}    ${Available - Pending}
    
    Open Work Order Queue Window    
	Complete Work Order    ${WORK_ORDER_1},${WORK_ORDER_2}
	Close Work Order Queue
	Wait For Property On Properties Pane    ${Port Status}    ${Available}

	# 14. Re-create the Add Patch job and complete the job with new 6xLC assembly in purple from:
	# _Panel 01// 01 (MPO12-6xLC)/ 1-1 -> 6-6 to Switch 01// 01-06
	# _Panel 02// 01 (MPO12-6xLC)/ 1-1 -> 6-6 to Server 01// 01-06
	Open Patching Window    ${tree_node_panel_1}    ${01}
    Create Patching    patchFrom=${tree_node_panel_1}    patchTo=${tree_node_switch_1}
    ...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05},${06}    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}   createWo=${True}    clickNext=${True}	
    Create Work Order    ${WORK_ORDER_1}
    Wait For Property On Properties Pane    ${Port Status}    ${In Use - Pending}
    
    Open Patching Window    ${tree_node_panel_2}    ${01}
    Create Patching    patchFrom=${tree_node_panel_2}    patchTo=${tree_node_server_1_card_1}
    ...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05},${06}    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}   createWo=${True}    clickNext=${True}	
    Create Work Order    ${WORK_ORDER_2}
    Wait For Property On Properties Pane    ${Port Status}    ${In Use - Pending}
    
    Open Work Order Queue Window    
	Complete Work Order    ${WORK_ORDER_1},${WORK_ORDER_2}
	Close Work Order Queue
	Wait For Property On Properties Pane    ${Port Status}    ${In Use}

	# 15. Observe the port icons, the port statuses, the propagated services and trace horizontal and vertical them
	# _Port icons for:
	# +Switch 01// 01-06: patched icon (including purple icon)
	# +Panel 01-02// 01: cabled and patched icons
	# +Server 01// 01-06: patched icon
	# _Port statuses for Switch 01// 01-06, Panel 01-02// 01 and Server 01// 01-06: In Use
	# _Data service is propagated on the Properties pane/window of Panel 01-02// 01 and Server 01// 01-06.
	# _The circuit trace displays:
	# +Current View: Switch 01// 01-06/ 1 [1-1] - 6 [6-6] -> patched to -> Panel 01// 01/ 1 [A1] -> cabled to -> Panel 02// 01/ 1 [A1] -> patched to -> Server 01// 01-06/ 1 [1-1] - 6 [6-6]    

    :FOR    ${i}    IN RANGE    0    len(${port_list}) 	  
	\    Open Trace Window    ${tree_node_switch_1}    ${port_list}[${i}]	    
	\    Check Total Trace On Site Manager    5    	
	\    Check Trace Object On Site Manager    indexObject=1    objectPosition=since:2020-03-23    objectPath=${Config}: /${VLAN}: ${vlan_list}[${i}]/${Service}: ${Data}    objectType=${Trace Service Object}
	...    connectionType=${Trace Assign}    informationDevice=${Service}:->${Data}->${VLAN}: ${vlan_list}[${i}]->${Config}:
	\    Check Trace Object On Site Manager    indexObject=2    objectPosition=${object_position_list}[${i}] [${pair_list_2}[${i}]]    objectPath=${tree_node_switch_1}/${port_list}[${i}]    objectType=${Trace Managed Switch}
	...    portIcon=${PortNEFDServiceInUse}    connectionType=${TRACE_LC_6X_MPO12_EB_PATCHING}    informationDevice=${port_list}[${i}]->${SWITCH_NAME_3}->${ip_address}->${device_information_rack_1}
	\    Check Trace Object On Site Manager    indexObject=3    objectPosition=${1} [${A1}]    objectPath=${tree_node_panel_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
	...    mpoType=${12}    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
	...    informationDevice=${01}->${PANEL_NAME_1}->${device_information_rack_1}	
	\    Check Trace Object On Site Manager    indexObject=4    objectPosition=${1} [${A1}]    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
	...    mpoType=${12}    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
	...    informationDevice=${01}->${PANEL_NAME_2}->${device_information_rack_1}
	\    Check Trace Object On Site Manager    indexObject=5    objectPosition=${object_position_list}[${i}] [${pair_list_2}[${i}]]    objectPath=${tree_node_server_1_card_1}/${port_list}[${i}]    objectType=${Trace ServerCard}
	...    portIcon=${PortFDUncabledInUse}    informationDevice=${port_list}[${i}]->${CARD_NAME_1}->${SERVER_NAME_1}->${device_information_rack_1}
	\    Close Trace Window
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortNEFDServiceInUse}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${In Use}    ${i+1}
	
    Open Trace Window    ${tree_node_panel_1}    ${01}
    :FOR    ${i}    IN RANGE    0    len(${port_list}) 	    
	\    Select View Trace Tab On Site Manager    ${pair_list_2}[${i}]	    
	\    Check Total Trace On Site Manager    5    	
	\    Check Trace Object On Site Manager    indexObject=1    objectPosition=since:2020-03-23    objectPath=${Config}: /${VLAN}: ${vlan_list}[${i}]/${Service}: ${Data}    objectType=${Trace Service Object}
	...    connectionType=${Trace Assign}    informationDevice=${Service}:->${Data}->${VLAN}: ${vlan_list}[${i}]->${Config}:
	\    Check Trace Object On Site Manager    indexObject=2    objectPosition=${object_position_list}[${i}] [${pair_list_2}[${i}]]    objectPath=${tree_node_switch_1}/${port_list}[${i}]    objectType=${Trace Managed Switch}
	...    portIcon=${PortNEFDServiceInUse}    connectionType=${TRACE_LC_6X_MPO12_EB_PATCHING}    informationDevice=${port_list}[${i}]->${SWITCH_NAME_3}->${ip_address}->${device_information_rack_1}
	\    Check Trace Object On Site Manager    indexObject=3    objectPosition=${1} [${A1}]    objectPath=${tree_node_panel_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
	...    mpoType=${12}    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
	...    informationDevice=${01}->${PANEL_NAME_1}->${device_information_rack_1}	
	\    Check Trace Object On Site Manager    indexObject=4    objectPosition=${1} [${A1}]    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
	...    mpoType=${12}    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
	...    informationDevice=${01}->${PANEL_NAME_2}->${device_information_rack_1}
	\    Check Trace Object On Site Manager    indexObject=5    objectPosition=${object_position_list}[${i}] [${pair_list_2}[${i}]]    objectPath=${tree_node_server_1_card_1}/${port_list}[${i}]    objectType=${Trace ServerCard}
	...    portIcon=${PortFDUncabledInUse}    informationDevice=${port_list}[${i}]->${CARD_NAME_1}->${SERVER_NAME_1}->${device_information_rack_1}
	Close Trace Window	  
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOPanelCabledInUse}   
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}    1 
	Check Object Properties On Properties Pane    ${Service}    ${Data}
	
	Open Trace Window    ${tree_node_panel_2}    ${01}
    :FOR    ${i}    IN RANGE    0    len(${port_list}) 	
	\    Select View Trace Tab On Site Manager    ${pair_list_2}[${i}]	    
	\    Check Total Trace On Site Manager    5    	
	\    Check Trace Object On Site Manager    indexObject=1    objectPosition=since:2020-03-23    objectPath=${Config}: /${VLAN}: ${vlan_list}[${i}]/${Service}: ${Data}    objectType=${Trace Service Object}
	...    connectionType=${Trace Assign}    informationDevice=${Service}:->${Data}->${VLAN}: ${vlan_list}[${i}]->${Config}:
	\    Check Trace Object On Site Manager    indexObject=2    objectPosition=${object_position_list}[${i}] [${pair_list_2}[${i}]]    objectPath=${tree_node_switch_1}/${port_list}[${i}]    objectType=${Trace Managed Switch}
	...    portIcon=${PortNEFDServiceInUse}    connectionType=${TRACE_LC_6X_MPO12_EB_PATCHING}    informationDevice=${port_list}[${i}]->${SWITCH_NAME_3}->${ip_address}->${device_information_rack_1}
	\    Check Trace Object On Site Manager    indexObject=3    objectPosition=${1} [${A1}]    objectPath=${tree_node_panel_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
	...    mpoType=${12}    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
	...    informationDevice=${01}->${PANEL_NAME_1}->${device_information_rack_1}	
	\    Check Trace Object On Site Manager    indexObject=4    objectPosition=${1} [${A1}]    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
	...    mpoType=${12}    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
	...    informationDevice=${01}->${PANEL_NAME_2}->${device_information_rack_1}
	\    Check Trace Object On Site Manager    indexObject=5    objectPosition=${object_position_list}[${i}] [${pair_list_2}[${i}]]    objectPath=${tree_node_server_1_card_1}/${port_list}[${i}]    objectType=${Trace ServerCard}
	...    portIcon=${PortFDUncabledInUse}    informationDevice=${port_list}[${i}]->${CARD_NAME_1}->${SERVER_NAME_1}->${device_information_rack_1}
	Close Trace Window
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOPanelCabledInUse}    
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}    1
	Check Object Properties On Properties Pane    ${Service}    ${Data}

    :FOR    ${i}    IN RANGE    0    len(${port_list}) 	
	\    Open Trace Window    ${tree_node_server_1_card_1}    ${port_list}[${i}]	    
	\    Check Total Trace On Site Manager    5    	
	\    Check Trace Object On Site Manager    indexObject=1    objectPosition=since:2020-03-23    objectPath=${Config}: /${VLAN}: ${vlan_list}[${i}]/${Service}: ${Data}    objectType=${Trace Service Object}
	...    connectionType=${Trace Assign}    informationDevice=${Service}:->${Data}->${VLAN}: ${vlan_list}[${i}]->${Config}:
	\    Check Trace Object On Site Manager    indexObject=2    objectPosition=${object_position_list}[${i}] [${pair_list_2}[${i}]]    objectPath=${tree_node_switch_1}/${port_list}[${i}]    objectType=${Trace Managed Switch}
	...    portIcon=${PortNEFDServiceInUse}    connectionType=${TRACE_LC_6X_MPO12_EB_PATCHING}    informationDevice=${port_list}[${i}]->${SWITCH_NAME_3}->${ip_address}->${device_information_rack_1}
	\    Check Trace Object On Site Manager    indexObject=3    objectPosition=${1} [${A1}]    objectPath=${tree_node_panel_1}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
	...    mpoType=${12}    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
	...    informationDevice=${01}->${PANEL_NAME_1}->${device_information_rack_1}	
	\    Check Trace Object On Site Manager    indexObject=4    objectPosition=${1} [${A1}]    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
	...    mpoType=${12}    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
	...    informationDevice=${01}->${PANEL_NAME_2}->${device_information_rack_1}
	\    Check Trace Object On Site Manager    indexObject=5    objectPosition=${object_position_list}[${i}] [${pair_list_2}[${i}]]    objectPath=${tree_node_server_1_card_1}/${port_list}[${i}]    objectType=${Trace ServerCard}
	...    portIcon=${PortFDUncabledInUse}    informationDevice=${port_list}[${i}]->${CARD_NAME_1}->${SERVER_NAME_1}->${device_information_rack_1}
	\    Close Trace Window
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortFDUncabledInUse}    
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${In Use}    ${i+1}
	\    Check Object Properties On Properties Pane    ${Current Service}    ${Data}

SM-29808_SM-29832_31_Verify that after converting DB, the service is propagated and trace correctly in customer circuit: LC Switch -> cabled 6xLC to -> MPO12 Panel -> F2B cabling to -> MPO12 Panel -> patched 6xLC to -> LC Server
    [Setup]    Run Keywords    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
            
    [Teardown]    Close Browser
        
    ${tree_node_rack_1}    Set Variable    ${SITE_NODE}/${BUILDING_NAME}/${FLOOR_NAME_2}/${ROOM_NAME}/${RACK_GROUP_NAME}/${ZONE}:${POSITION} ${RACK_NAME}   
    ${tree_node_panel_1_module_1a}    Set Variable    ${tree_node_rack_1}/${PANEL_NAME_1}/${Module 1A} (${Pass-Through})
    ${tree_node_panel_2}    Set Variable    ${tree_node_rack_1}/${PANEL_NAME_2}
    ${tree_node_server_1}    Set Variable    ${tree_node_rack_1}/${SERVER_NAME_1} 
    ${tree_node_switch_gbic_slot_1}    Set Variable    ${tree_node_rack_1}/${SWITCH_NAME_1}/${GBIC_SLOT_1}  
    ${device_information_rack_1}    Set Variable    ${ZONE}:${POSITION} ${RACK_NAME}->${RACK_GROUP_NAME}->${ROOM_NAME}->${FLOOR_NAME_2}->${BUILDING_NAME}->${SITE_NODE}   
	${trace_module_1a}	Set Variable	${Module 1A} (${Pass-Through})
        
    ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}       
    ${object_position_list}    Create List    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}
    ${pair_list_1}	Create List    ${A1-2}    ${A3-4}    ${A5-6}    ${A7-8}    ${A9-10}    ${A11-12}
    ${pair_list_2}	Create List    ${Pair 1}    ${Pair 2}    ${Pair 3}    ${Pair 4}    ${Pair 5}    ${Pair 6}    

    # 1. Prepare two test machines: 
	# _Machine 1: Install the previous SM Build (e.g. SM9.1)
	# _Machine 2: Install the latest SM Build
	# 2. Launch and log into SM Web of machine 1
	# 3. Go to "Site Manager" page
	# 4. Add: 
	# _LC Switch 01 to Room 01
	# _MPO non-iPatch Panel 01 to Rack 001
	# _MPO Panel 02, LC Server 01 to Rack 001
	# 5. Set Data service for Switch 01// 01-06 directly
	# 6. Cable from Panel 01// 01 (MPO12-6xLC)/ A1-2 -> A11-12 to Switch 01// 01-06
	# 7. F2B cabling from Panel 01// 01 (MPO12-MPO12) to Panel 02// 01
	# 8. Create the Add Patch job and complete the job from Panel 02// 01 (MPO12-6xLC)/ A1-2 -> A11-12 to Server 01// 01-06
	# 9. Observe the port icons, the port statuses, the propagated services and trace horizontal and vertical them
	# 10. Backup this DB then restore this DB to machine 2 successfully
	# 11. Launch and log into SM Web of machine 2
	# 12. Go to "Site Manager" page
	# 13. Observe the port icons, the port statuses, the propagated services and trace horizontal and vertical them
	# _Port icons for: 
	# +Switch 01// 01-06: patched icon (including purple icon)
	# +Panel 01-02// 01: cabled and patched icons
	# +Server 01// 01-06: patched icon
	# _Port statuses for: 
	# +Switch 01// 01-06, Panel 01-02// 01 and Server 01// 01-06: In Use
	# _Data service is propagated on the Properties pane/window of Panel 01-02// 01 and Server 01// 01-06.
	# _The circuit trace displays: 
	# +Current View: Switch 01// 01-06/ 1 [A1-2] - 6 [A11-12] -> cabled to -> Panel 01// 01/ 1 [/A1] -> F2B cabling to -> Panel 02// 01/ 1 [A1] -> patched to -> Server 01// 06-01/ 6 [A11-12] - 1 [A1-2]    
	
	:FOR    ${i}    IN RANGE    0    len(${port_list}) 
	\    ${i1}=    Evaluate    len(${port_list})-1-${i}    
	\    Open Trace Window    ${tree_node_switch_gbic_slot_1}    ${port_list}[${i}]	    
	\    Check Total Trace On Site Manager    5    	
	\    Check Trace Object On Site Manager    indexObject=1    objectPath=${Config}: /${VLAN}: /${Service}: ${Data}    objectType=${Trace Service Object}
	...    connectionType=${Trace Assign}    informationDevice=${Service}:->${Data}->${VLAN}:->${Config}:
	\    Check Trace Object On Site Manager    indexObject=2    objectPosition=${object_position_list}[${i}] [${pair_list_1}[${i}]]    objectPath=${tree_node_switch_gbic_slot_1}/${port_list}[${i}]    objectType=${Trace Switch}
	...    portIcon=${PortNEFDServiceCabled}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_CABLING}    informationDevice=${port_list}[${i}]->${GBIC_SLOT_1}->${SWITCH_NAME_1}->${device_information_rack_1}
	\    Check Trace Object On Site Manager    indexObject=3    objectPosition=${1} [ /${A1}]    objectPath=${tree_node_panel_1_module_1a}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
	...    mpoType=${12}    portIcon=${PortMPOServiceCabledInUse}    connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}
	...    informationDevice=${01}->${trace_module_1a}->${PANEL_NAME_1}->${device_information_rack_1}	
	\    Check Trace Object On Site Manager    indexObject=4    objectPosition=${1} [${A1}]    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
	...    mpoType=${12}    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_6X_LC_PATCHING}
	...    informationDevice=${01}->${PANEL_NAME_2}->${device_information_rack_1}
	\    Check Trace Object On Site Manager    indexObject=5    objectPosition=${object_position_list}[${i1}] [${pair_list_1}[${i1}]]    objectPath=${tree_node_server_1}/${port_list}[${i1}]    objectType=${Trace Server Fiber}
	...    portIcon=${PortFDUncabledInUse}    informationDevice=${port_list}[${i1}]->${SERVER_NAME_1}->${device_information_rack_1}
	\    Close Trace Window
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortNEFDServiceCabled}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${In Use}    ${i+1}
	
    Open Trace Window    ${tree_node_panel_1_module_1a}    ${01}
    :FOR    ${i}    IN RANGE    0    len(${port_list}) 
	\    ${i1}=    Evaluate    len(${port_list})-1-${i}    
	\    Select View Trace Tab On Site Manager    ${pair_list_1}[${i}]	    
	\    Check Total Trace On Site Manager    5    	
	\    Check Trace Object On Site Manager    indexObject=1    objectPath=${Config}: /${VLAN}: /${Service}: ${Data}    objectType=${Trace Service Object}
	...    connectionType=${Trace Assign}    informationDevice=${Service}:->${Data}->${VLAN}:->${Config}:
	\    Check Trace Object On Site Manager    indexObject=2    objectPosition=${object_position_list}[${i}] [${pair_list_1}[${i}]]    objectPath=${tree_node_switch_gbic_slot_1}/${port_list}[${i}]    objectType=${Trace Switch}
	...    portIcon=${PortNEFDServiceCabled}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_CABLING}    informationDevice=${port_list}[${i}]->${GBIC_SLOT_1}->${SWITCH_NAME_1}->${device_information_rack_1}
	\    Check Trace Object On Site Manager    indexObject=3    objectPosition=${1} [ /${A1}]    objectPath=${tree_node_panel_1_module_1a}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
	...    mpoType=${12}    portIcon=${PortMPOServiceCabledInUse}    connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}
	...    informationDevice=${01}->${trace_module_1a}->${PANEL_NAME_1}->${device_information_rack_1}	
	\    Check Trace Object On Site Manager    indexObject=4    objectPosition=${1} [${A1}]    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
	...    mpoType=${12}    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_6X_LC_PATCHING}
	...    informationDevice=${01}->${PANEL_NAME_2}->${device_information_rack_1}
	\    Check Trace Object On Site Manager    indexObject=5    objectPosition=${object_position_list}[${i1}] [${pair_list_1}[${i1}]]    objectPath=${tree_node_server_1}/${port_list}[${i1}]    objectType=${Trace Server Fiber}
	...    portIcon=${PortFDUncabledInUse}    informationDevice=${port_list}[${i1}]->${SERVER_NAME_1}->${device_information_rack_1}
	Close Trace Window	   
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOServiceCabledInUse}   
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}    1
	Check Object Properties On Properties Pane    ${Service}    ${Data}
	
	Open Trace Window    ${tree_node_panel_2}    ${01}
    :FOR    ${i}    IN RANGE    0    len(${port_list}) 
	\    ${i1}=    Evaluate    len(${port_list})-1-${i}    
	\    Select View Trace Tab On Site Manager    ${pair_list_1}[${i}]	    
	\    Check Total Trace On Site Manager    5    	
	\    Check Trace Object On Site Manager    indexObject=1    objectPath=${Config}: /${VLAN}: /${Service}: ${Data}    objectType=${Trace Service Object}
	...    connectionType=${Trace Assign}    informationDevice=${Service}:->${Data}->${VLAN}:->${Config}:
	\    Check Trace Object On Site Manager    indexObject=2    objectPosition=${object_position_list}[${i1}] [${pair_list_1}[${i1}]]    objectPath=${tree_node_switch_gbic_slot_1}/${port_list}[${i1}]    objectType=${Trace Switch}
	...    portIcon=${PortNEFDServiceCabled}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_CABLING}    informationDevice=${port_list}[${i1}]->${GBIC_SLOT_1}->${SWITCH_NAME_1}->${device_information_rack_1}
	\    Check Trace Object On Site Manager    indexObject=3    objectPosition=${1} [ /${A1}]    objectPath=${tree_node_panel_1_module_1a}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
	...    mpoType=${12}    portIcon=${PortMPOServiceCabledInUse}    connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}
	...    informationDevice=${01}->${trace_module_1a}->${PANEL_NAME_1}->${device_information_rack_1}	
	\    Check Trace Object On Site Manager    indexObject=4    objectPosition=${1} [${A1}]    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
	...    mpoType=${12}    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_6X_LC_PATCHING}
	...    informationDevice=${01}->${PANEL_NAME_2}->${device_information_rack_1}
	\    Check Trace Object On Site Manager    indexObject=5    objectPosition=${object_position_list}[${i}] [${pair_list_1}[${i}]]    objectPath=${tree_node_server_1}/${port_list}[${i}]    objectType=${Trace Server Fiber}
	...    portIcon=${PortFDUncabledInUse}    informationDevice=${port_list}[${i}]->${SERVER_NAME_1}->${device_information_rack_1}
	Close Trace Window
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOPanelCabledInUse}    
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}    1
	Check Object Properties On Properties Pane    ${Service}    ${Data}

    :FOR    ${i}    IN RANGE    0    len(${port_list}) 
	\    ${i1}=    Evaluate    len(${port_list})-1-${i}    
	\    Open Trace Window    ${tree_node_server_1}    ${port_list}[${i}]	    
	\    Check Total Trace On Site Manager    5    	
	\    Check Trace Object On Site Manager    indexObject=1    objectPath=${Config}: /${VLAN}: /${Service}: ${Data}    objectType=${Trace Service Object}
	...    connectionType=${Trace Assign}    informationDevice=${Service}:->${Data}->${VLAN}:->${Config}:
	\    Check Trace Object On Site Manager    indexObject=2    objectPosition=${object_position_list}[${i1}] [${pair_list_1}[${i1}]]    objectPath=${tree_node_switch_gbic_slot_1}/${port_list}[${i1}]    objectType=${Trace Switch}
	...    portIcon=${PortNEFDServiceCabled}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_CABLING}    informationDevice=${port_list}[${i1}]->${GBIC_SLOT_1}->${SWITCH_NAME_1}->${device_information_rack_1}
	\    Check Trace Object On Site Manager    indexObject=3    objectPosition=${1} [ /${A1}]    objectPath=${tree_node_panel_1_module_1a}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
	...    mpoType=${12}    portIcon=${PortMPOServiceCabledInUse}    connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}
	...    informationDevice=${01}->${trace_module_1a}->${PANEL_NAME_1}->${device_information_rack_1}	
	\    Check Trace Object On Site Manager    indexObject=4    objectPosition=${1} [${A1}]    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
	...    mpoType=${12}    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_6X_LC_PATCHING}
	...    informationDevice=${01}->${PANEL_NAME_2}->${device_information_rack_1}
	\    Check Trace Object On Site Manager    indexObject=5    objectPosition=${object_position_list}[${i}] [${pair_list_1}[${i}]]    objectPath=${tree_node_server_1}/${port_list}[${i}]    objectType=${Trace Server Fiber}
	...    portIcon=${PortFDUncabledInUse}    informationDevice=${port_list}[${i}]->${SERVER_NAME_1}->${device_information_rack_1}
	\    Close Trace Window
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortFDUncabledInUse}    
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${In Use}    ${i+1}
	\    Check Object Properties On Properties Pane    ${Current Service}    ${Data}

	# 14. Remove cabling from Panel 01// 01 (MPO12-6xLC)/ A1-2 -> A11-12 to Switch 01// 01-06
    # 15. Create the Remove Patch job and complete the job from Panel 02// 01 (MPO12-6xLC)/ 1-1 -> 6-6 to Server 01// 01-06
       
    Open Cabling Window    ${tree_node_panel_1_module_1a}    ${01}    
    Create Cabling    typeConnect=DisConnect    cableFrom=${tree_node_panel_1_module_1a}/${01}    cableTo=${tree_node_switch_gbic_slot_1}    
    ...    mpoBranches=${A1-2},${A3-4},${A5-6},${A7-8},${A9-10},${A11-12}
    ...    portsTo=${01},${02},${03},${04},${05},${06}
    Close Cabling Window        

    Open Patching Window    ${tree_node_panel_2}    ${01}
    Create Patching    patchFrom=${tree_node_panel_2}    patchTo=${tree_node_server_1}    typeConnect=Disconnect
    ...    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC}    mpoBranches=${A1-2},${A3-4},${A5-6},${A7-8},${A9-10},${A11-12}
    ...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05},${06}    createWo=${True}    clickNext=${True}	
    Create Work Order    ${WORK_ORDER_1}
    Wait For Property On Properties Pane    ${Port Status}    ${Available - Pending}
    
    Open Work Order Queue Window    
	Complete Work Order    ${WORK_ORDER_1}
	Close Work Order Queue
	Wait For Property On Properties Pane    ${Port Status}    ${Available}

	# 16. Re-cabling with new 6xLC assembly in purple from Panel 01// 01 (MPO12-6xLC)/ 1-1 -> 6-6 to Switch 01// 01-06
    # 17. Re-create the Add Patch job and complete the job with new 6xLC assembly in purple from Panel 02// 01 (MPO12-6xLC)/ 1-1 -> 6-6 to Server 01// 01-06
	    
    Open Cabling Window    ${tree_node_panel_1_module_1a}    ${01}    
    Create Cabling    typeConnect=Connect    cableFrom=${tree_node_panel_1_module_1a}/${01}    cableTo=${tree_node_switch_gbic_slot_1}
    ...    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}
    ...    portsTo=${01},${02},${03},${04},${05},${06}
    Close Cabling Window  
    
    Open Patching Window    ${tree_node_panel_2}    ${01}
    Create Patching    patchFrom=${tree_node_panel_2}    patchTo=${tree_node_server_1}
    ...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05},${06}    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}   createWo=${True}    clickNext=${True}	
    Create Work Order    ${WORK_ORDER_1}
    Wait For Property On Properties Pane    ${Port Status}    ${In Use - Pending}
    
    Open Work Order Queue Window    
	Complete Work Order    ${WORK_ORDER_1}
	Close Work Order Queue
	Wait For Property On Properties Pane    ${Port Status}    ${In Use}

    # 18. Observe the port icons, the port statuses, the propagated services and trace horizontal and vertical them
    # _Port icons for: 
	# +Switch 01// 01-06: patched icon (including purple icon)
	# +Panel 01-02// 01: cabled and patched icons
	# +Server 01// 01-06: patched icon
	# _Port statuses for: 
	# +Switch 01// 01-06, Panel 01-02// 01 and Server 01// 01-06: In Use
	# _Data service is propagated on the Properties pane/window of Panel 01-02// 01 and Server 01// 01-06.
	# _The circuit trace displays: 
	# +Current View: Switch 01// 01-06/ 1 [1-1] - 6 [6-6] -> cabled to -> Panel 01// 01/ 1 [/A1] -> F2B cabling to -> Panel 02// 01/ 1 [A1] -> patched to -> Server 01// 01-06/ 1 [1-1] - 6 [6-6]

    :FOR    ${i}    IN RANGE    0    len(${port_list}) 	  
	\    Open Trace Window    ${tree_node_switch_gbic_slot_1}    ${port_list}[${i}]	    
	\    Check Total Trace On Site Manager    5    	
	\    Check Trace Object On Site Manager    indexObject=1    objectPath=${Config}: /${VLAN}: /${Service}: ${Data}    objectType=${Trace Service Object}
	...    connectionType=${Trace Assign}    informationDevice=${Service}:->${Data}->${VLAN}:->${Config}:
	\    Check Trace Object On Site Manager    indexObject=2    objectPosition=${object_position_list}[${i}] [${pair_list_2}[${i}]]    objectPath=${tree_node_switch_gbic_slot_1}/${port_list}[${i}]    objectType=${Trace Switch}
	...    portIcon=${PortNEFDServiceCabled}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}    informationDevice=${port_list}[${i}]->${GBIC_SLOT_1}->${SWITCH_NAME_1}->${device_information_rack_1}
	\    Check Trace Object On Site Manager    indexObject=3    objectPosition=${1} [ /${A1}]    objectPath=${tree_node_panel_1_module_1a}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
	...    mpoType=${12}    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}
	...    informationDevice=${01}->${trace_module_1a}->${PANEL_NAME_1}->${device_information_rack_1}	
	\    Check Trace Object On Site Manager    indexObject=4    objectPosition=${1} [${A1}]    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
	...    mpoType=${12}    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
	...    informationDevice=${01}->${PANEL_NAME_2}->${device_information_rack_1}
	\    Check Trace Object On Site Manager    indexObject=5    objectPosition=${object_position_list}[${i}] [${pair_list_2}[${i}]]    objectPath=${tree_node_server_1}/${port_list}[${i}]    objectType=${Trace Server Fiber}
	...    portIcon=${PortFDUncabledInUse}    informationDevice=${port_list}[${i}]->${SERVER_NAME_1}->${device_information_rack_1}
	\    Close Trace Window
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortNEFDServiceCabled}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${In Use}    ${i+1}
	
    Open Trace Window    ${tree_node_panel_1_module_1a}    ${01}
    :FOR    ${i}    IN RANGE    0    len(${port_list}) 	    
	\    Select View Trace Tab On Site Manager    ${pair_list_2}[${i}]	    
	\    Check Total Trace On Site Manager    5    	
	\    Check Trace Object On Site Manager    indexObject=1    objectPath=${Config}: /${VLAN}: /${Service}: ${Data}    objectType=${Trace Service Object}
	...    connectionType=${Trace Assign}    informationDevice=${Service}:->${Data}->${VLAN}:->${Config}:
	\    Check Trace Object On Site Manager    indexObject=2    objectPosition=${object_position_list}[${i}] [${pair_list_2}[${i}]]    objectPath=${tree_node_switch_gbic_slot_1}/${port_list}[${i}]    objectType=${Trace Switch}
	...    portIcon=${PortNEFDServiceCabled}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}    informationDevice=${port_list}[${i}]->${GBIC_SLOT_1}->${SWITCH_NAME_1}->${device_information_rack_1}
	\    Check Trace Object On Site Manager    indexObject=3    objectPosition=${1} [ /${A1}]    objectPath=${tree_node_panel_1_module_1a}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
	...    mpoType=${12}    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}
	...    informationDevice=${01}->${trace_module_1a}->${PANEL_NAME_1}->${device_information_rack_1}	
	\    Check Trace Object On Site Manager    indexObject=4    objectPosition=${1} [${A1}]    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
	...    mpoType=${12}    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
	...    informationDevice=${01}->${PANEL_NAME_2}->${device_information_rack_1}
	\    Check Trace Object On Site Manager    indexObject=5    objectPosition=${object_position_list}[${i}] [${pair_list_2}[${i}]]    objectPath=${tree_node_server_1}/${port_list}[${i}]    objectType=${Trace Server Fiber}
	...    portIcon=${PortFDUncabledInUse}    informationDevice=${port_list}[${i}]->${SERVER_NAME_1}->${device_information_rack_1}
	Close Trace Window	   
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOPanelCabledInUse}   
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}    1 
    Check Object Properties On Properties Pane    ${Service}    ${Data}
	
	Open Trace Window    ${tree_node_panel_2}    ${01}
    :FOR    ${i}    IN RANGE    0    len(${port_list}) 	
	\    Select View Trace Tab On Site Manager    ${pair_list_2}[${i}]	    
	\    Check Total Trace On Site Manager    5    	
	\    Check Trace Object On Site Manager    indexObject=1    objectPath=${Config}: /${VLAN}: /${Service}: ${Data}    objectType=${Trace Service Object}
	...    connectionType=${Trace Assign}    informationDevice=${Service}:->${Data}->${VLAN}:->${Config}:
	\    Check Trace Object On Site Manager    indexObject=2    objectPosition=${object_position_list}[${i}] [${pair_list_2}[${i}]]    objectPath=${tree_node_switch_gbic_slot_1}/${port_list}[${i}]    objectType=${Trace Switch}
	...    portIcon=${PortNEFDServiceCabled}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}    informationDevice=${port_list}[${i}]->${GBIC_SLOT_1}->${SWITCH_NAME_1}->${device_information_rack_1}
	\    Check Trace Object On Site Manager    indexObject=3    objectPosition=${1} [ /${A1}]    objectPath=${tree_node_panel_1_module_1a}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
	...    mpoType=${12}    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}
	...    informationDevice=${01}->${trace_module_1a}->${PANEL_NAME_1}->${device_information_rack_1}	
	\    Check Trace Object On Site Manager    indexObject=4    objectPosition=${1} [${A1}]    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
	...    mpoType=${12}    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
	...    informationDevice=${01}->${PANEL_NAME_2}->${device_information_rack_1}
	\    Check Trace Object On Site Manager    indexObject=5    objectPosition=${object_position_list}[${i}] [${pair_list_2}[${i}]]    objectPath=${tree_node_server_1}/${port_list}[${i}]    objectType=${Trace Server Fiber}
	...    portIcon=${PortFDUncabledInUse}    informationDevice=${port_list}[${i}]->${SERVER_NAME_1}->${device_information_rack_1}
	Close Trace Window
	Check Icon Object Exist On Content Pane    ${01}    ${PortMPOPanelCabledInUse}    
    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}    1
	Check Object Properties On Properties Pane    ${Service}    ${Data}

    :FOR    ${i}    IN RANGE    0    len(${port_list}) 	
	\    Open Trace Window    ${tree_node_server_1}    ${port_list}[${i}]	    
	\    Check Total Trace On Site Manager    5    	
	\    Check Trace Object On Site Manager    indexObject=1    objectPath=${Config}: /${VLAN}: /${Service}: ${Data}    objectType=${Trace Service Object}
	...    connectionType=${Trace Assign}    informationDevice=${Service}:->${Data}->${VLAN}:->${Config}:
	\    Check Trace Object On Site Manager    indexObject=2    objectPosition=${object_position_list}[${i}] [${pair_list_2}[${i}]]    objectPath=${tree_node_switch_gbic_slot_1}/${port_list}[${i}]    objectType=${Trace Switch}
	...    portIcon=${PortNEFDServiceCabled}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}    informationDevice=${port_list}[${i}]->${GBIC_SLOT_1}->${SWITCH_NAME_1}->${device_information_rack_1}
	\    Check Trace Object On Site Manager    indexObject=3    objectPosition=${1} [ /${A1}]    objectPath=${tree_node_panel_1_module_1a}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
	...    mpoType=${12}    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_FRONT_TO_BACK_CABLING}
	...    informationDevice=${01}->${trace_module_1a}->${PANEL_NAME_1}->${device_information_rack_1}	
	\    Check Trace Object On Site Manager    indexObject=4    objectPosition=${1} [${A1}]    objectPath=${tree_node_panel_2}/${01}    objectType=${TRACE_GENERIC_MPO_PANEL_IMAGE}
	...    mpoType=${12}    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
	...    informationDevice=${01}->${PANEL_NAME_2}->${device_information_rack_1}
	\    Check Trace Object On Site Manager    indexObject=5    objectPosition=${object_position_list}[${i}] [${pair_list_2}[${i}]]    objectPath=${tree_node_server_1}/${port_list}[${i}]    objectType=${Trace Server Fiber}
	...    portIcon=${PortFDUncabledInUse}    informationDevice=${port_list}[${i}]->${SERVER_NAME_1}->${device_information_rack_1}
	\    Close Trace Window
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortFDUncabledInUse}    
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${In Use}    ${i+1}
	\    Check Object Properties On Properties Pane    ${Current Service}    ${Data}

SM-29808_SM-29832_32_Verify that after converting DB, the service is propagated and trace correctly in customer circuit: LC Switch -> cabled 6xLC to -> InstaPatch -> patched to -> LC Server
    [Setup]    Run Keywords    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
            
    [Teardown]    Close Browser
        
    ${tree_node_rack_1}    Set Variable    ${SITE_NODE}/${BUILDING_NAME}/${FLOOR_NAME_3}/${ROOM_NAME}/${ZONE}:${POSITION} ${RACK_NAME}    
    ${tree_node_panel_1_module_1a}    Set Variable    ${tree_node_rack_1}/${PANEL_NAME_1}/${Module 1A} (${Alpha})
    ${tree_node_switch_1_card_1}    Set Variable    ${SITE_NODE}/${BUILDING_NAME}/${FLOOR_NAME_3}/${ROOM_NAME}/${SWITCH_NAME_1}/${CARD_NAME_1}  
    ${tree_node_server_1_card_1}    Set Variable    ${tree_node_rack_1}/${SERVER_NAME_1}/${CARD_NAME_1}  
    ${device_information_rack_1}    Set Variable    ${ZONE}:${POSITION} ${RACK_NAME}->${ROOM_NAME}->${FLOOR_NAME_3}->${BUILDING_NAME}->${SITE_NODE}
	${device_information_room_1}    Set Variable    ${ROOM_NAME}->${FLOOR_NAME_3}->${BUILDING_NAME}->${SITE_NODE}
               
    ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}       
    ${object_position_list}    Create List    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}
    
    # 1. Prepare two test machines: 
	# _Machine 1: Install the previous SM Build (e.g. SM9.1)
	# _Machine 2: Install the latest SM Build
	# 2. Launch and log into SM Web of machine 1
	# 3. Go to "Site Manager" page
	# 4. Add: 
	# _LC Switch 01 to Room 01
	# _InstaPatch Panel 01 (Alpha/Beta), LC Server 01 to Rack 001
	# 5. Set Data service for Switch 01// 01-06 directly
	# 6. Cable from Panel 01// MPO 01 (MPO12-6xLC)/ A1-2 -> A11-12 to Switch 01// 01-06
	# 7. Create the Add Patch job and complete the job from Panel 01// 01-06 to Server 01// 01-06
	# 8. Observe the port icons, the port statuses, the propagated services and trace horizontal and vertical them
	# 9. Backup this DB then restore this DB to machine 2 successfully
	# 10. Launch and log into SM Web of machine 2
	# 11. Go to "Site Manager" page
	# 12. Observe the port icons, the port statuses, the propagated services and trace horizontal and vertical them
	# _Port icons for: 
	# +Switch 01// 01-06: patched icon (including purple icon)
	# +Panel 01// 01-06: cabled and patched icons
	# +Server 01// 01-06: patched icon
	# _Port statuses for Switch 01// 01-06, Panel 01// 01-06 and Server 01// 01-06: In Use
	# _Data service is propagated on the Properties pane/window of Panel 01// 01-06 and Server 01// 01-06.
	# _The circuit trace displays: 
	# +Current View: Switch 01// 01-06/ 1-6 -> cabled to -> Panel 01// 01-06/ 1-6 (MPO1) -> patched to -> Server 01// 01-06/ 1-6    
	
	:FOR    ${i}    IN RANGE    0    len(${port_list}) 	
	\    Open Trace Window    ${tree_node_switch_1_card_1}    ${port_list}[${i}]	    
	\    Check Total Trace On Site Manager    4    	
	\    Check Trace Object On Site Manager    indexObject=1    objectPath=${Config}: /${VLAN}: /${Service}: ${Data}    objectType=${Trace Service Object}
	...    connectionType=${Trace Assign}    informationDevice=${Service}:->${Data}->${VLAN}:->${Config}:
	\    Check Trace Object On Site Manager    indexObject=2    objectPosition=${object_position_list}[${i}]    objectPath=${tree_node_switch_1_card_1}/${port_list}[${i}]    objectType=${Trace NonManagedSwitchCard}
	...    portIcon=${PortNEFDServiceCabled}    connectionType=${TRACE_FIBER_FRONT_TO_BACK_CABLING}    informationDevice=${port_list}[${i}]->${CARD_NAME_1}->${SWITCH_NAME_1}->${device_information_room_1}
	\    Check Trace Object On Site Manager    indexObject=3    objectPosition=${object_position_list}[${i}] (${MPO1})    objectPath=${tree_node_panel_1_module_1a}/${port_list}[${i}]    objectType=${Trace 360 instapatch Fiber Shelf}
	...    portIcon=${PortNEFDServiceInUse}    connectionType=${TRACE_FIBER_PATCHING}
	...    informationDevice=${port_list}[${i}]->${Module 1A} (${Alpha})->${PANEL_NAME_1}->${device_information_rack_1}		
	\    Check Trace Object On Site Manager    indexObject=4    objectPosition=${object_position_list}[${i}]    objectPath=${tree_node_server_1_card_1}/${port_list}[${i}]    objectType=${Trace ServerCard}
	...    portIcon=${PortFDUncabledInUse}    informationDevice=${port_list}[${i}]->${CARD_NAME_1}->${SERVER_NAME_1}->${device_information_rack_1}
	\    Close Trace Window
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortNEFDServiceCabled}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${In Use}    ${i+1}
	
    :FOR    ${i}    IN RANGE    0    len(${port_list}) 	
	\    Open Trace Window    ${tree_node_panel_1_module_1a}    ${port_list}[${i}]	    
	\    Check Total Trace On Site Manager    4    	
	\    Check Trace Object On Site Manager    indexObject=1    objectPath=${Config}: /${VLAN}: /${Service}: ${Data}    objectType=${Trace Service Object}
	...    connectionType=${Trace Assign}    informationDevice=${Service}:->${Data}->${VLAN}:->${Config}:
	\    Check Trace Object On Site Manager    indexObject=2    objectPosition=${object_position_list}[${i}]    objectPath=${tree_node_switch_1_card_1}/${port_list}[${i}]    objectType=${Trace NonManagedSwitchCard}
	...    portIcon=${PortNEFDServiceCabled}    connectionType=${TRACE_FIBER_FRONT_TO_BACK_CABLING}    informationDevice=${port_list}[${i}]->${CARD_NAME_1}->${SWITCH_NAME_1}->${device_information_room_1}
	\    Check Trace Object On Site Manager    indexObject=3    objectPosition=${object_position_list}[${i}] (${MPO1})    objectPath=${tree_node_panel_1_module_1a}/${port_list}[${i}]    objectType=${Trace 360 instapatch Fiber Shelf}
	...    portIcon=${PortNEFDServiceInUse}    connectionType=${TRACE_FIBER_PATCHING}
	...    informationDevice=${port_list}[${i}]->${Module 1A} (${Alpha})->${PANEL_NAME_1}->${device_information_rack_1}		
	\    Check Trace Object On Site Manager    indexObject=4    objectPosition=${object_position_list}[${i}]    objectPath=${tree_node_server_1_card_1}/${port_list}[${i}]    objectType=${Trace ServerCard}
	...    portIcon=${PortFDUncabledInUse}    informationDevice=${port_list}[${i}]->${CARD_NAME_1}->${SERVER_NAME_1}->${device_information_rack_1}
	\    Close Trace Window
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortNEFDServiceInUse}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${In Use}    ${i+1}
	\    Check Object Properties On Properties Pane    ${Service}    ${Data}
	
    :FOR    ${i}    IN RANGE    0    len(${port_list}) 	
	\    Open Trace Window    ${tree_node_server_1_card_1}    ${port_list}[${i}]	    
	\    Check Total Trace On Site Manager    4    	
	\    Check Trace Object On Site Manager    indexObject=1    objectPath=${Config}: /${VLAN}: /${Service}: ${Data}    objectType=${Trace Service Object}
	...    connectionType=${Trace Assign}    informationDevice=${Service}:->${Data}->${VLAN}:->${Config}:
	\    Check Trace Object On Site Manager    indexObject=2    objectPosition=${object_position_list}[${i}]    objectPath=${tree_node_switch_1_card_1}/${port_list}[${i}]    objectType=${Trace NonManagedSwitchCard}
	...    portIcon=${PortNEFDServiceCabled}    connectionType=${TRACE_FIBER_FRONT_TO_BACK_CABLING}    informationDevice=${port_list}[${i}]->${CARD_NAME_1}->${SWITCH_NAME_1}->${device_information_room_1}
	\    Check Trace Object On Site Manager    indexObject=3    objectPosition=${object_position_list}[${i}] (${MPO1})    objectPath=${tree_node_panel_1_module_1a}/${port_list}[${i}]    objectType=${Trace 360 instapatch Fiber Shelf}
	...    portIcon=${PortNEFDServiceInUse}    connectionType=${TRACE_FIBER_PATCHING}
	...    informationDevice=${port_list}[${i}]->${Module 1A} (${Alpha})->${PANEL_NAME_1}->${device_information_rack_1}		
	\    Check Trace Object On Site Manager    indexObject=4    objectPosition=${object_position_list}[${i}]    objectPath=${tree_node_server_1_card_1}/${port_list}[${i}]    objectType=${Trace ServerCard}
	...    portIcon=${PortFDUncabledInUse}    informationDevice=${port_list}[${i}]->${CARD_NAME_1}->${SERVER_NAME_1}->${device_information_rack_1}
	\    Close Trace Window
	\    Check Icon Object Exist On Content Pane    ${port_list}[${i}]    ${PortFDUncabledInUse}
	\    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${In Use}    ${i+1}
	\    Check Object Properties On Properties Pane    ${Current Service}    ${Data}
    
	# 13. Remove cabling Panel 01// MPO 01 (MPO12-6xLC)/ A1-2 -> A11-12 to Switch 01// 01-06
	# 14. Re-cabling with new 6xLC assembly in purple from Panel 01// MPO 01 (MPO12-6xLC)/ 1-1 -> 6-6 to Switch 01// 01-06	   
	# 15. Observe the result
	# New 6xLC assembly icon in purple is disabled and user cannot create new 6xLC assembly for InstaPatch. (Refer to the user story SM-29803 for more details)
       
    Open Cabling Window    ${SITE_NODE}/${BUILDING_NAME}        
    Create Cabling    typeConnect=DisConnect    cableFrom=${tree_node_panel_1_module_1a}/${MPO} ${01}    cableTo=${tree_node_switch_1_card_1}    
    ...    portsTo=${01},${02},${03},${04},${05},${06}
              		    
	Click Tree Node Cabling    From    ${tree_node_panel_1_module_1a}/${MPO} ${01}	   
    :FOR    ${i}    IN RANGE    0    len(${port_list})    
    \    Click Tree Node Cabling    To    ${tree_node_switch_1_card_1}/${port_list}[${i}]
    \    Check Mpo Connection Type State On Cabling Window    mpoConnectionType=${Mpo12_6xLC_EB}    isEnabled=${False}    mpoConnectionTab=${MPO12}   
    Close Cabling Window  

(Bulk_SM-29808_26_27_28_29)_Verify that user cannot create cabling MPO12-6xLC from InstaPatch Port
    [Setup]    Run Keywords    Set Test Variable    ${building_name_SM_29808}    SM_29808_26_27_28_29
    ...    AND    Delete Building    name=${building_name_SM_29808}    
    ...    AND    Add New Building    ${building_name_SM_29808}        
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
            
    [Teardown]    Run Keywords    Close Browser
    ...    AND    Delete Building   name=${building_name_SM_29808}    
    
    ${tree_node_room}    Set Variable    ${SITE_NODE}/${building_name_SM_29808}/${FLOOR_NAME_1}/${ROOM_NAME}
    ${tree_node_rack}    Set Variable    ${tree_node_room}/${ZONE}:${POSITION} ${RACK_NAME}
    ${tree_node_panel_1_module_1a}    Set Variable    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1A} (${Alpha})
    ${tree_node_panel_1_module_1b}    Set Variable    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1B} (${Beta})
    ${tree_node_panel_1_module_1c}    Set Variable    ${tree_node_rack}/${PANEL_NAME_1}/${Module 1C} (${DM24})
    ${tree_node_panel_2}    Set Variable    ${tree_node_rack}/${PANEL_NAME_2}    
    ${tree_node_faceplate}    Set Variable    ${tree_node_room}/${FACEPLATE_NAME}
    ${tree_node_switch_1}    Set Variable    ${tree_node_rack}/${SWITCH_NAME_1}
    ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}
    
    Add Floor    ${SITE_NODE}/${building_name_SM_29808}    ${FLOOR_NAME_1}
    Add Room    ${SITE_NODE}/${building_name_SM_29808}/${FLOOR_NAME_1}    ${ROOM_NAME}
    Add Rack    ${SITE_NODE}/${building_name_SM_29808}/${FLOOR_NAME_1}/${ROOM_NAME}    ${RACK_NAME}
    Add Ipatch Fiber Equipment    ${tree_node_rack}    ${360 G2 iPatch - 2U}    ${PANEL_NAME_1}
    ...    ${Module 1A},True,${LC 12 Port},${Alpha};${Module 1B},True,${LC 12 Port},${Beta};${Module 1C},True,${LC 12 Port},${DM24}        	
    Add Generic Panel    ${tree_node_rack}    ${PANEL_NAME_2}    portType=${LC}
    Add Faceplate    ${tree_node_room}    ${FACEPLATE_NAME}   
    Add Network Equipment    ${tree_node_rack}    ${SWITCH_NAME_1}    
    Add Network Equipment Port    ${tree_node_rack}/${SWITCH_NAME_1}    name=${01}    portType=${LC}    quantity=6

    # TC SM-29808_26:	Verify that user cannot create cabling MPO12-6xLC from InstaPatch Port (Alpha/Beta) to LC Panel Port
    # 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	# 3. Add:
	# _InstaPatch Panel 01 (Alpha/Beta)
	# _LC Panel 02	
	# 4. Cabling from Panel 01// MPO 01 (MPO12-6xLC)/ 1-1 -> 6-6 to Panel 02// 01-06
	# 5. Observe MPO12-6x LC EB connection in MPO12 Connection tab
	# VP: MPO12-6x LC EB connection in MPO12 Connection tab should be disabled.
    Open Cabling Window    ${SITE_NODE}/${building_name_SM_29808}     
    Click Tree Node Cabling    From    ${SITE_NODE}
	Click Tree Node Cabling    From    ${tree_node_panel_1_module_1a}/${MPO} ${01}	   
    :FOR    ${i}    IN RANGE    0    len(${port_list})    
    \    Click Tree Node Cabling    To    ${tree_node_panel_2}/${port_list}[${i}]
    \    Check Mpo Connection Type State On Cabling Window    mpoConnectionType=${Mpo12_6xLC_EB}    isEnabled=${False}    mpoConnectionTab=${MPO12}     
   	
    # TC SM-29808_27:	Verify that user cannot create cabling MPO12-6xLC from InstaPatch Port (Alpha/Beta) to LC Outlet
    # 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	# 3. Add:
	# _InstaPatch Panel 01 (Alpha/Beta)
	# _LC Faceplate 01	
	# 4. Cabling from Panel 01// MPO 01 (MPO12-6xLC)/ 1-1 -> 6-6 to Faceplate 01/ 01-06
	# 5. Observe MPO12-6x LC EB connection in MPO12 Connection tab
	# VP: MPO12-6x LC EB connection in MPO12 Connection tab should be disabled
    Click Tree Node Cabling    From    ${tree_node_panel_1_module_1b}/${MPO} ${01}	   
    :FOR    ${i}    IN RANGE    0    len(${port_list})    
    \    Click Tree Node Cabling    To    ${tree_node_faceplate}/${port_list}[${i}]
    \    Check Mpo Connection Type State On Cabling Window    mpoConnectionType=${Mpo12_6xLC_EB}    isEnabled=${False}    mpoConnectionTab=${MPO12}
    
    # TC SM-29808_28:	Verify that user cannot create cabling MPO12-6xLC from InstaPatch Port (Alpha/Beta) to LC Switch Port
    # 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	# 3. Add:
	# _InstaPatch Panel 01 (Alpha/Beta)
	# _LC Switch 01 (or Managed Switch and sync it successfully)
	# 4. Cabling from Panel 01// MPO 01 (MPO12-6xLC)/ 1-1 -> 6-6 to Switch 01// 01-06
	# 5. Observe MPO12-6x LC EB connection in MPO12 Connection tab
	# VP: MPO12-6x LC EB connection in MPO12 Connection tab should be disabled.
	Click Tree Node Cabling    From    ${tree_node_panel_1_module_1b}/${MPO} ${01}	   
    :FOR    ${i}    IN RANGE    0    len(${port_list})    
    \    Click Tree Node Cabling    To    ${tree_node_switch_1}/${port_list}[${i}]
    \    Check Mpo Connection Type State On Cabling Window    mpoConnectionType=${Mpo12_6xLC_EB}    isEnabled=${False}    mpoConnectionTab=${MPO12}

    # TC SM-29808_29:	Verify that user cannot create cabling MPO12-6xLC from InstaPatch Port (DM24) to LC Panel Port
    # 1. Launch and log into SM Web
	# 2. Go to "Site Manager" page
	# 3. Add:
	# _InstaPatch Panel 01 (DM24)
	# _LC Panel 02
	# 4. Open Cabling window
	# 5. Select Panel 01// MPO 01 in the left pane and select Panel 02// 01 in the right pane
	# 6. Try to select the "MPO12-6xLC " connectivity type
	# 7. Observe the result
	# VP: The "MPO24-6xLC" connectivity type is disabled.
	Click Tree Node Cabling    From    ${tree_node_panel_1_module_1c}/${MPO} ${01}	   
    :FOR    ${i}    IN RANGE    0    len(${port_list})    
    \    Click Tree Node Cabling    To    ${tree_node_panel_2}/${port_list}[${i}]
    \    Check Mpo Connection Type State On Cabling Window    mpoConnectionType=${Mpo12_6xLC_EB}    isEnabled=${False}    mpoConnectionTab=${MPO12}
    Close Cabling Window
