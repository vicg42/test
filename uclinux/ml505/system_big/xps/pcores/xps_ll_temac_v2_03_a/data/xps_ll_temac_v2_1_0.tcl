###############################################################################
##
## Copyright (c) 2007 Xilinx, Inc. All Rights Reserved.
##
## xps_ll_temac_v2_1_0.tcl
##
###############################################################################

## @BEGIN_CHANGELOG EDK_K_SP2
##
## - added more checks for PHY interface ports
##
## @END_CHANGELOG


## @BEGIN_CHANGELOG EDK_Jm
##
## - initial 1.00a version
##
## @END_CHANGELOG

#***--------------------------------***-----------------------------------***
#
#			     IPLEVEL_UPDATE_VALUE_PROC
#
#***--------------------------------***-----------------------------------***

## This procedure sets C_FAMILY to base family
# if the design is targeting a derivative architecture
proc update_cfamily {param_handle} {
    set orig_family [xget_hw_proj_setting "fpga_family"]
            puts "orig_family is $orig_family"
    if {[xstrncmp $orig_family "spartan6l"] || [xstrncmp $orig_family "qspartan6"] || [xstrncmp $orig_family "qspartan6l"] || [xstrncmp $orig_family "aspartan6"] || [xstrncmp $orig_family "spartan6t"]} {
        return "spartan6"
    } elseif  {[xstrncmp $orig_family "virtex6l"] || [xstrncmp $orig_family "qvirtex6"]} {
        return "virtex6"
    } elseif  {[xstrncmp $orig_family "qrvirtex5"]} {
        return "virtex5"
    } elseif {[xstrncmp $orig_family "qvirtex4"] || [xstrncmp $orig_family "qrvirtex4"]} {
        return "virtex4"
    } elseif  {[xstrncmp $orig_family "aspartan3"]} {
        return "spartan3"
    } else {
        return $orig_family
    }
} 


#***--------------------------------***-----------------------------------***
#
#			     IPLEVEL_DRC_PROC
#
#***--------------------------------***-----------------------------------***

#-----------------------------------------
# C_TEMAC_TYPE = 0 - V5 Hard TEMAC
# C_TEMAC_TYPE = 1 - V4 Hard TEMAC
# C_TEMAC_TYPE = 2 - Soft TEMAC
# C_TEMAC_TYPE = 3 - V6 Hard TEMAC
#-----------------------------------------
proc check_iplevel_settings {mhsinst} {

    set device  [xget_hw_parameter_value $mhsinst "C_FAMILY" ]
    set sub_fam [xget_hw_parameter_value $mhsinst "C_SUBFAMILY"]
    set type    [xget_hw_parameter_value $mhsinst "C_TEMAC_TYPE"]

    if {[string length $device] == 0} {
	return
    }

    if {[string compare -nocase $device "virtex6"] == 0} {

        # if device is V6, C_TEMAC_TYPE = 3 or 2
	if {$type == 1} {

	    error "\n The parameter C_TEMAC_TYPE cannot be 1 (V4 hard) for [string toupper $device] architecture.\n" "" "mdt_error"

	} 
	if {$type == 0} {

	    error "\n The parameter C_TEMAC_TYPE cannot be 0 (V5 hard) for [string toupper $device] architecture.\n" "" "mdt_error"

	}

    } elseif {[string compare -nocase $device "virtex6l"] == 0} {

        # if device is V6, C_TEMAC_TYPE = 3 or 2
	if {$type == 1} {

	    error "\n The parameter C_TEMAC_TYPE cannot be 1 (V4 hard) for [string toupper $device] architecture.\n" "" "mdt_error"

	} 
	if {$type == 0} {

	    error "\n The parameter C_TEMAC_TYPE cannot be 0 (V5 hard) for [string toupper $device] architecture.\n" "" "mdt_error"

	}

    } elseif {[string compare -nocase $device "qvirtex6"] == 0} {

        # if device is V6, C_TEMAC_TYPE = 3 or 2
	if {$type == 1} {

	    error "\n The parameter C_TEMAC_TYPE cannot be 1 (V4 hard) for [string toupper $device] architecture.\n" "" "mdt_error"

	} 
	if {$type == 0} {

	    error "\n The parameter C_TEMAC_TYPE cannot be 0 (V5 hard) for [string toupper $device] architecture.\n" "" "mdt_error"

	}

    } elseif {[string compare -nocase $device "virtex5"] == 0} {

        # if device is V5, C_TEMAC_TYPE = 0 or 2
	if {$type == 1} {

	    error "\n The parameter C_TEMAC_TYPE cannot be 1 (V4 hard) for [string toupper $device] architecture.\n" "" "mdt_error"

	} 
	if {$type == 3} {

	    error "\n The parameter C_TEMAC_TYPE cannot be 3 (V6 hard) for [string toupper $device] architecture.\n" "" "mdt_error"

	}

    } elseif {[string compare -nocase $device "qrvirtex5"] == 0} {

        # if device is V5, C_TEMAC_TYPE = 0 or 2
	if {$type == 1} {

	    error "\n The parameter C_TEMAC_TYPE cannot be 1 (V4 hard) for [string toupper $device] architecture.\n" "" "mdt_error"

	} 
	if {$type == 3} {

	    error "\n The parameter C_TEMAC_TYPE cannot be 3 (V6 hard) for [string toupper $device] architecture.\n" "" "mdt_error"

	}

    } elseif {[string compare -nocase $device "virtex4"] == 0 && [string compare -nocase $sub_fam "FX"] == 0} {

    	# if device is V4FX, C_TEMAC_TYPE = 1 or 2
	if {$type == 0} {

	    error "\n The parameter C_TEMAC_TYPE cannot be 0 (V5 hard) for [string toupper $device$sub_fam] architecture.\n" "" "mdt_error"

	}
	if {$type == 3} {

	    error "\n The parameter C_TEMAC_TYPE cannot be 3 (V6 hard) for [string toupper $device] architecture.\n" "" "mdt_error"

	}

    } elseif {[string compare -nocase $device "qvirtex4"] == 0 && [string compare -nocase $sub_fam "FX"] == 0} {

    	# if device is V4FX, C_TEMAC_TYPE = 1 or 2
	if {$type == 0} {

	    error "\n The parameter C_TEMAC_TYPE cannot be 0 (V5 hard) for [string toupper $device$sub_fam] architecture.\n" "" "mdt_error"

	}
	if {$type == 3} {

	    error "\n The parameter C_TEMAC_TYPE cannot be 3 (V6 hard) for [string toupper $device] architecture.\n" "" "mdt_error"

	}

    } elseif {[string compare -nocase $device "qrvirtex4"] == 0 && [string compare -nocase $sub_fam "FX"] == 0} {

    	# if device is V4FX, C_TEMAC_TYPE = 1 or 2
	if {$type == 0} {

	    error "\n The parameter C_TEMAC_TYPE cannot be 0 (V5 hard) for [string toupper $device$sub_fam] architecture.\n" "" "mdt_error"

	}
	if {$type == 3} {

	    error "\n The parameter C_TEMAC_TYPE cannot be 3 (V6 hard) for [string toupper $device] architecture.\n" "" "mdt_error"

	}

    } else {  

	# other devices, C_TEMAC_TYPE = 2
	if {$type != 2} {

	    error "\n The parameter C_TEMAC_TYPE can only be 2 (soft, licence required) for [string toupper $device] [string toupper $device$sub_fam] architecture.\n" "" "mdt_error"

	}
    }
}


#***--------------------------------***------------------------------------***
#
#			     SYSLEVEL_DRC_PROC
#
#***--------------------------------***------------------------------------***

# check the connectivity of GMII_*_0 and GMII_*_1 ports
# if  C_PHY_TYPE=1 and C_INCLUDE_IO=1 then
# 	ports GMII_*_0 much be connected to a top level net
# if  C_PHY_TYPE=1 and C_INCLUDE_IO=1 and C_TEMAC1_ENABLED=1 then
# 	ports GMII_*_1 much be connected to a top level net
#
proc check_syslevel_settings { mhsinst } {

    set phy_type   [xget_hw_parameter_value $mhsinst "C_PHY_TYPE"]
    set incld_io   [xget_hw_parameter_value $mhsinst "C_INCLUDE_IO"]
    set tm_enabled [xget_hw_parameter_value $mhsinst "C_TEMAC1_ENABLED"]

    if {$phy_type == 0 && $incld_io == 1} {

        set portList {MII_TXD MII_TX_EN MII_TX_ER MII_TX_CLK MII_RXD MII_RX_DV MII_RX_ER MII_RX_CLK}

	# MII_*_0 should be connected to top level
        check_ports_connectivity $mhsinst $portList "_0"

	if {$tm_enabled == 1} {

	    # MII_*_1 should be connected to top level
            check_ports_connectivity $mhsinst $portList "_1"
	}
    }

    if {$phy_type == 1 && $incld_io == 1} {

        set portList {GMII_TXD GMII_TX_EN GMII_TX_ER GMII_TX_CLK MII_TX_CLK GMII_RXD GMII_RX_DV GMII_RX_ER GMII_RX_CLK}

	# GMII_*_0 should be connected to top level
        check_ports_connectivity $mhsinst $portList "_0"

	if {$tm_enabled == 1} {

	    # GMII_*_1 should be connected to top level
            check_ports_connectivity $mhsinst $portList "_1"
	}
    }

    if {$phy_type == 2 && $incld_io == 1} {

        set portList {RGMII_TXD RGMII_TX_CTL RGMII_TXC RGMII_RXD RGMII_RX_CTL RGMII_RXC}

	# RGMII_*_0 should be connected to top level
        check_ports_connectivity $mhsinst $portList "_0"

	if {$tm_enabled == 1} {

	    # RGMII_*_1 should be connected to top level
            check_ports_connectivity $mhsinst $portList "_1"
	}
    }

    if {$phy_type == 3 && $incld_io == 1} {

        set portList {RGMII_TXD RGMII_TX_CTL RGMII_TXC RGMII_RXD RGMII_RX_CTL RGMII_RXC}

	# RGMII_*_0 should be connected to top level
        check_ports_connectivity $mhsinst $portList "_0"

	if {$tm_enabled == 1} {

	    # RGMII_*_1 should be connected to top level
            check_ports_connectivity $mhsinst $portList "_1"
	}
    }

    if {$phy_type == 4 && $incld_io == 1} {

        set portList {TXP TXN RXP RXN}

	# RGMII_*_0 should be connected to top level
        #check_ports_connectivity $mhsinst $portList "_0" commented out to allow just MGT channel 1 to be used

	if {$tm_enabled == 1} {

	    # RGMII_*_1 should be connected to top level
            check_ports_connectivity $mhsinst $portList "_1"
	}
    }

    if {$phy_type == 5 && $incld_io == 1} {

        set portList {TXP TXN RXP RXN}

	# RGMII_*_0 should be connected to top level
        #check_ports_connectivity $mhsinst $portList "_0" commented out to allow just MGT channel 1 to be used

	if {$tm_enabled == 1} {

	    # RGMII_*_1 should be connected to top level
            check_ports_connectivity $mhsinst $portList "_1"
	}
    }
}

proc check_ports_connectivity {mhsinst portList ext} {

    foreach portname $portList {

	append portname $ext
        set    globalList [xget_connected_global_ports $mhsinst $portname]

        if { [llength $globalList] == 0 } {

            error  "\n The port $portname is not connected directly to an external port.\n" "" "mdt_error"

        }
    }
}


#***--------------------------------***------------------------------------***
#
# 		         Update ConfigIP Gui Parameters 
#
#***--------------------------------***------------------------------------***

#-------------------------------------------
# called by MPMC Gui before gui is up
#-------------------------------------------
proc xps_ipconfig_init {mhsinst} {

    set device    [xget_hw_parameter_value $mhsinst "C_FAMILY"]
    set sub_fam   [xget_hw_parameter_value $mhsinst "C_SUBFAMILY"]
    set type_list ""

    if {[string compare -nocase $device "virtex5"] == 0} {

	set type_list "(0= V5 Hard, 2= Soft-lic required )"
    } elseif {[string compare -nocase $device "virtex4"] == 0 && [string compare -nocase $sub_fam "FX"] == 0} {

	set type_list "(1= V4 Hard, 2= Soft-lic required )"
    } elseif {[string compare -nocase $device "virtex6"] == 0} {
 
        set type_list "(2= Soft-lic required, 3= V6 Hard )"
    } else {

	set type_list "(2= Soft-lic required )"
    set temac_handle [xget_hw_parameter_handle $mhsinst "C_TEMAC_TYPE"]
    xset_hw_parameter_value $temac_handle "2"
    }

    # update VALUES tag to C_TEMAC_TYPE

    set param_handle    [xget_hw_parameter_handle $mhsinst "C_TEMAC_TYPE"]
    xadd_hw_subproperty $param_handle             "VALUES" $type_list

    xps_update_phy_type $mhsinst
}

#***--------------------------------***-----------------------------------***
#
#			     CORE_LEVEL_CONSTRAINTS
#
#***--------------------------------***-----------------------------------***


proc generate_corelevel_ucf {mhsinst} {

    set  filePath [xget_ncf_dir $mhsinst]

    file mkdir    $filePath

    # specify file name
    set    instname   [xget_hw_parameter_value $mhsinst "INSTANCE"]
    set    ipname     [xget_hw_option_value    $mhsinst "IPNAME"]
    set    name_lower [string   tolower   $instname]
    set    fileName   $name_lower
    append fileName   "_wrapper.ucf"
    append filePath   $fileName

    # Open a file for writing
    set    outputFile [open $filePath "w"]

    #---------------------------------------------------------------------
    #     BEGIN: C_IDELAYCTRL_LOC dependent constraints
    #---------------------------------------------------------------------

    # The following constraints are parameter C_IDELAYCTRL_LOC dependent
    set loc_values [xget_hw_parameter_value $mhsinst "C_IDELAYCTRL_LOC" ]  
    # the value must be set
    if { [string length $loc_values] == 0 } {

   	puts  "\nWARNING:  $instname ($ipname) -\n      The parameter C_IDELAYCTRL_LOC must be set.\n"

    } else {

    	# if this is not a default - "NOT_SET", then generate ucf file
    	if { [string compare -nocase $loc_values "NOT_SET"] != 0 } {

	    # get a list by splitting $loc_values at each "-"
	    set vlist       [split $loc_values -]
	    set vlist_upper [string toupper $vlist]
	    set list_length [llength $vlist_upper]
	    set idelay_num  [xget_hw_parameter_value $mhsinst "C_NUM_IDELAYCTRL" ] 

	    # The list length must be equal to C_NUM_IDELAYCTRL
	    if { [string compare $list_length $idelay_num] == 0 } {

	        # check if any invalid pair value
	        foreach value $vlist_upper {

	       	    if { [regexp IDELAYCTRL_X\[0-9\]\?\[0-9\]Y\[0-9\]\?\[0-9\] $value] == 0 } {

		    	error "\n Invalid parameter C_IDELAYCTRL_LOC = $loc_values" "" "mdt_error"

		    }

		}

		set suffix 0
			 
	    	foreach value $vlist_upper {

		    puts   $outputFile "INST \"${instname}/*gen_instantiate_idelayctrls\[${suffix}\].idelayctrl0\"   LOC = \"${value}\";"
		    incr suffix

		}  
	    } else {

	    	error "\n parameter C_IDELAYCTRL_LOC must have a list of value equals to C_NUM_IDELAYCTRL" "" "mdt_error"

	    }

	}

    }

    # Close the file
    close $outputFile
    puts  [xget_ncf_loc_info $mhsinst]

}

proc xps_update_phy_type {mhsinst} {
    
    set c_temac_type_value [xget_hw_parameter_value $mhsinst "C_TEMAC_TYPE"]
    set c_phy_type_handle [xget_hw_parameter_handle $mhsinst "C_PHY_TYPE"]
    set values ""

    if { [string compare -nocase $c_temac_type_value "2"] == 0 } {
        set values "(0= MII, 1= GMII )"
    } else {
        set values "(0= MII, 1= GMII, 2=  RGMII V1.3 , 3= RGMII V2.0 , 4=SGMII, 5=  1000Base-X )"
    }
    xadd_hw_subproperty $c_phy_type_handle             "VALUES" $values
}
