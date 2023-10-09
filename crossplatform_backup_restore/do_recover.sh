#!/bin/bash

ls inc_recover* | sort | awk '{print "rman target / @" $0}' > do_recover.rman

. do_recover.rman