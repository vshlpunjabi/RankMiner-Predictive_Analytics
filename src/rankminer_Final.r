agent <- read.csv('project_agent_data.csv',header = TRUE, stringsAsFactors = FALSE)
call <- read.csv('project_call_data.csv', header = TRUE, stringsAsFactors = FALSE)
feature <- read.csv('project_feature_data.csv',header =TRUE, stringsAsFactors = FALSE)
attach(agent)
attach(call)
attach(feature)
str(agent)
str(call)
str(feature)

agent[agent == ""] <- NA
call[call == ""] <- NA
feature[feature == ""] <- NA

#make src1 and src2 consistent
agent$payroll_id_src1[is.na(agent$payroll_id_src1)] <- agent$payroll_id_src2[is.na(agent$payroll_id_src1)]
agent$payroll_id_src2[is.na(agent$payroll_id_src2)] <- agent$payroll_id_src1[is.na(agent$payroll_id_src2)]

agent$hire_date_src1[is.na(agent$hire_date_src1)] <- agent$hire_date_src2[is.na(agent$hire_date_src1)]
agent$hire_date_src2[is.na(agent$hire_date_src2)] <- agent$hire_date_src1[is.na(agent$hire_date_src2)]

agent$term_date_src1[is.na(agent$term_date_src2)] <- agent$term_date_src1[is.na(agent$term_date_src2)]
agent$term_date_src1[is.na(agent$term_date_src1)] <- agent$term_date_src2[is.na(agent$term_date_src1)]

agent$work_shift_src1[is.na(agent$work_shift_src1)] <- agent$work_shift_src2[is.na(agent$work_shift_src1)]
agent$work_shift_src2[is.na(agent$work_shift_src2)] <- agent$work_shift_src1[is.na(agent$work_shift_src2)]

# Check if src1 and src2 are different
agent$payroll_id_src1[agent$payroll_id_src1!=agent$payroll_id_src2]
agent$payroll_id_src2[agent$payroll_id_src1!=agent$payroll_id_src2]

agent$hire_date_src1[agent$hire_date_src1!=agent$hire_date_src2 ]
agent$hire_date_src2[agent$hire_date_src1!=agent$hire_date_src2]

agent$term_date_src1[agent$term_date_src1!=agent$term_date_src2 & !is.na(agent$term_date_src1) & !is.na(agent$term_date_src2)]
agent$term_date_src2[agent$term_date_src1!=agent$term_date_src2  & !is.na(agent$term_date_src1) & !is.na(agent$term_date_src2)]

agent$work_shift_src1[agent$work_shift_src1!=agent$work_shift_src2 & !is.na(agent$work_shift_src1) & !is.na(agent$work_shift_src2)]
agent$work_shift_src2[agent$work_shift_src1!=agent$work_shift_src2 & !is.na(agent$work_shift_src1) & !is.na(agent$work_shift_src2)]

length(agent$work_shift_src2[is.na(agent$work_shift_src2)])

#Delete src2
agent$payroll_id_src2 = NULL
agent$hire_date_src2 = NULL
agent$term_date_src2 = NULL
agent$work_shift_src2 = NULL

#agent - Setting all characters to uppercase

agent = data.frame(lapply(agent, function(v) {
  if (is.character(v)) return(toupper(v))
  else return(v)
}))

#call - Setting all characters to uppercase
call = data.frame(lapply(call, function(v) {
  if (is.character(v)) return(toupper(v))
  else return(v)
}))


names(agent)[names(agent)=="payroll_id_src1"] <- "payroll_id"
names(agent)[names(agent)=="hire_date_src1"] <- "hire_date"
names(agent)[names(agent)=="term_date_src1"] <- "term_date"
names(agent)[names(agent)=="work_shift_src1"] <- "work_shift"
names(agent)[names(agent)=="group_src1"] <- "group"

agent$terminated <- 0
agent$terminated[!is.na(agent$term_date) | !is.na(agent$term_code) | !is.na(agent$term_type) | !is.na(agent$term_reason)] <- 1

#analysis
table(agent$terminated)
table(agent$terminated,agent$term_type)
table(agent$terminated,agent$term_reason)
round(prop.table(table(agent$terminated[agent$terminated==1], agent$term_type[agent$terminated==1]), 1)*100)

##NOT REQUIRED -- DELETE LATER
agent_unique_l <- lapply(agent[,c("group","work_shift","term_code","term_type","term_reason","Jul_group","Aug_group","Sep_group","Oct_group","Nov_group","Dec_group")], unique)
agent_unique_max.ln <- max(sapply(agent_unique_l, length))
agent_unique_l <- lapply(agent_unique_l, function(v) { c(v, rep(NA, agent_unique_max.ln-length(v)))})
agent_unique <- as.data.frame(agent_unique_l)
agent_unique <- apply(agent_unique,2,sort,decreasing=F)

#Change Names of Call Data
names(call)[names(call)=="ACCOUNT"] <- "account"
names(call)[names(call)=="AUDIO.FILE.NAME"] <- "audio_file_name"
names(call)[names(call)=="SKILL.NAME"] <- "skill_name"
names(call)[names(call)=="CALL.START.TIME"] <- "call_start"
names(call)[names(call)=="CALL.END.TIME"] <- "call_end"
names(call)[names(call)=="AGENT.ID"] <- "agent_id"
names(call)[names(call)=="CALL.DIRECTION"] <- "call_direction"
names(call)[names(call)=="CALL.DURATION.HMS"] <- "call_duration"
names(call)[names(call)=="FILESIZE.KB"] <- "audio_file_size"
names(call)[names(call)=="REC.STATUS"] <- "call_end_status"



##########################################################
##Unique values in the call dataset --- DELETE LATER
call_unique_l <- apply(call[,c("skill_name","call_direction","call_end_status")],2,sort,decreasing=F)
call_unique_l <- lapply(call_unique_l, unique)
call_unique_max.ln <- max(sapply(call_unique_l, length))
call_unique_l <- lapply(call_unique_l, function(v) { c(v, rep(NA, call_unique_max.ln-length(v)))})
call_unique <- as.data.frame(call_unique_l)
#####################################################

#Some outlier - 102474 to be removed from Dec_Group
agent$Dec_group = as.character(agent$Dec_group)
agent$Dec_group[agent$Dec_group==102474]=NA

#Converting NA's in term_type to UNKNOWN for reasons unknown
#agent$term_type[which(!is.na(agent$term_date) & is.na(agent$term_type))]="UN"

.#Tenure
agent$tenure <- NA
agent$tenure <- as.Date(agent$term_date) - as.Date(agent$hire_date)

#Termination Month
agent$term_month <- NA
agent$term_month <- format(as.Date(agent$term_date), "%m")

#Hire Month
agent$hire_month <- NA
agent$hire_month <- ifelse(as.numeric(format(as.Date(agent$hire_date), "%Y")) == 2015, as.numeric(format(as.Date(agent$hire_date), "%m")),as.numeric(7))


#Checking whether any person has a term date missing but term_type,code or reason present.
agent$term_code[is.na(agent$term_date)]
agent$term_type[is.na(agent$term_date)]
agent$term_reason[is.na(agent$term_date)]


#User groups with #N/A values converted to Other
agent[,c("Jul_group","Aug_group","Sep_group","Oct_group","Nov_group","Dec_group")] =
  sapply(agent[,c("Jul_group","Aug_group","Sep_group","Oct_group","Nov_group","Dec_group")],function(v){
    v = as.character(v)
    v[which(v=="#N/A")] = "OTHER"
    v
  })


#Consolidating.. 
#unique(agent$Jul_group)

##-------------Data Cleaning--------------
myreplace <- function(v,old,new){
  v= as.character(v)
  if(length(old)==length(new)){
    for(i in 1:length(old))
    {v[which(v==old[i])]= new[i]
    
    }
  }
  else{
    print("Check Old and New Values - they are unequal")
  }
  v
}

#########################
#Creating Vectors for new and old values to categorize the monthly group data
old_values = c("INB DSH" ,"DSH","PTM","VZ","INB SPR","SPR","G1A","G3A","DTV","COM","INB SPAN","INB A","INB B")
new_values = c("DISH","DISH","TMOBILE","VERIZON","SPRINT","SPRINT","CREDIT CARD","TELECOM","DIRECTV","COMMERCIAL","INBOUND","INBOUND","INBOUND")

agent[,c("Jul_group","Aug_group","Sep_group","Oct_group","Nov_group","Dec_group")]  =
  sapply(agent[,c("Jul_group","Aug_group","Sep_group","Oct_group","Nov_group","Dec_group")],myreplace,old=old_values,new=new_values)

######################################################################################
#Introducing Functional Groupings
old_functional_group = c("TMOBILE","SPRINT","VERIZON","TELECOM","ATT","DISH","DIRECTV","LEGAL","COMMERCIAL","AUTO","CREDIT CARD","INBOUND")

new_functional_group = c("CELL CARRIER","CELL CARRIER","CELL CARRIER","CELL CARRIER","CELL CARRIER","TV PROVIDER","TV PROVIDER","LEGAL","COMMERCIAL","AUTO","CREDIT CARD","INBOUND")

agent[c("JulFunctionalGroup","AugFunctionalGroup","SepFunctionalGroup","OctFunctionalGroup","NovFunctionalGroup","DecFunctionalGroup")] <- NA
agent[,c("JulFunctionalGroup","AugFunctionalGroup","SepFunctionalGroup","OctFunctionalGroup","NovFunctionalGroup","DecFunctionalGroup")] =
  sapply(agent[,c("Jul_group","Aug_group","Sep_group","Oct_group","Nov_group","Dec_group")],myreplace,old=old_functional_group,new=new_functional_group)

###----------------------------------------------------------------------------
#Creating List of User Groups
###----------------------------------------------------------------------------
for(i in 1:nrow(agent)){
  agent$usergroup[i]=list(c(as.character(agent$Jul_group[i]),as.character(agent$Aug_group[i]),as.character(agent$Sep_group[i]),as.character(agent$Oct_group[i]),as.character(agent$Nov_group[i]),as.character(agent$Dec_group[i])))
}

###----------------------
#Group Changes
###------------------------
agent$grpchange = NA
for(i in 1:nrow(agent)) {
  if(NA %in% agent$usergroup[[i]]){
    agent$grpchange[i]=length(unique(agent$usergroup[[i]]))-1
  }
  else {  agent$grpchange[i]=length(unique(agent$usergroup[[i]]))}
}

###---------------------------
##Last Group the agent worked under 
###----------------------------

agent$lastgrp = NA
agent$lastgrp = sapply(agent$usergroup,function(v){i = max(which(!is.na(v)));v[i] })

###-----------------------
#Fixing grp_src_1 (group) values -- Use "new_group" going forward for computations
###-----------------------
#Fixing group_src1 values - introducing new_group
grp_old = as.character(unique(agent$group))
grp_old = grp_old[!is.na(grp_old)]

grp_new = c("TELECOM","CREDIT CARD","VERIZON","TMOBILE","SPRINT","SPRINT","INBOUND","DISH","DISH","TELECOM","DIRECTV","INBOUND","AUTO","FM","COMMERICAL","LEGAL","TELECOM","FM","TELECOM","UNKNOWN")

agent$new_group <- NA
agent$new_group=sapply(agent$group,myreplace, old=grp_old,new=grp_new)


###------------------------
#Adding Synthetic Variables (Vishal)
###---------------------------

#Change This

agent$nom <-0
agent$nom <- ifelse(!is.na(agent$Jul_group),agent$nom+1,agent$nom)
agent$nom <- ifelse(!is.na(agent$Aug_group),agent$nom+1,agent$nom)
agent$nom <- ifelse(!is.na(agent$Sep_group),agent$nom+1,agent$nom)
agent$nom <- ifelse(!is.na(agent$Oct_group),agent$nom+1,agent$nom)
agent$nom <- ifelse(!is.na(agent$Nov_group),agent$nom+1,agent$nom)
agent$nom <- ifelse(!is.na(agent$Dec_group),agent$nom+1,agent$nom)

#term_type
agent$term_type_bin <- NA
agent$term_type_bin[agent$term_type == "VOLUNTARY"] <- 1
agent$term_type_bin[agent$term_type == "INVOLUNTARY"] <- 0
agent$term_type <- NULL
names(agent)[names(agent)=="term_type_bin"] <- "term_type"


#productivity
agent[,"Dec_hrs_worked"] <- as.numeric(agent[,"Dec_hrs_worked"])
agent$avghrsworked <- NA
agent$avghrsworked <- rowSums(agent[,c("Jul_hrs_worked","Aug_hrs_worked","Sep_hrs_worked","Oct_hrs_worked","Nov_hrs_worked","Dec_hrs_worked")],na.rm = TRUE)
agent$avghrsworked <- agent$avghrsworked/agent$nom

#rev_generated

agent$Oct_revenue_generated[which(agent$Oct_revenue_generated=="#N/A")]=NA
agent$Sep_revenue_generated[which(agent$Sep_revenue_generated=="#N/A")]=NA

#-- please check before converting from factors
agent[,"Oct_revenue_generated"] <- as.numeric(agent[,"Oct_revenue_generated"])
agent[,"Sep_revenue_generated"] <- as.numeric(agent[,"Sep_revenue_generated"])
agent$rev_generated <- NA
agent$rev_generated <- rowSums(agent[,c("Jul_revenue_generated","Aug_revenue_generated","Sep_revenue_generated","Oct_revenue_generated","Nov_revenue_generated","Dec_revenue_generated")],na.rm = TRUE)-rowSums(agent[,c("Jul_commission","Aug_commission","Sep_commission","Oct_commission","Nov_commission","Dec_commission")],na.rm = TRUE)
agent$rev_generated <- round(agent$rev_generated/agent$nom,3)

#commision - Change This
agent$commision <- 0

agent$commision <- ifelse(!is.na(agent$Jul_commission),agent$commision+1,agent$commision)
agent$commision <- ifelse(!is.na(agent$Aug_commission),agent$commision+1,agent$commision)
agent$commision <- ifelse(!is.na(agent$Sep_commission),agent$commision+1,agent$commision)
agent$commision <- ifelse(!is.na(agent$Oct_commission),agent$commision+1,agent$commision)
agent$commision <- ifelse(!is.na(agent$Nov_commission),agent$commision+1,agent$commision)
agent$commision <- ifelse(!is.na(agent$Dec_commission),agent$commision+1,agent$commision)
##0428
agent$commision <- agent$commision/agent$nom

#---------------------------
###Adding variables from Call Data
#----------------------------

#median call duration
library(data.table)
cz <- tapply(call$CALL.DURATION.HMS.,call$agent_id, median)
cz = data.frame(names(cz),cz)
names(cz) = c("agent_id","Call_Median_Duration")
agent = (merge(x = agent,y = cz, by = "agent_id", all.x = TRUE))


#no of calls
cy <- data.table(call)
cy <- tapply(call$account, call$agent_id, length)
cy = data.frame(names(cy),cy)
names(cy) = c("agent_id","Total_CallData_Calls")
agent = (merge(x = agent,y = cy, by = "agent_id", all.x = TRUE))

#names(agent)

#------------------------------------
#CALL DATA : REC-STATUS
###---------------------
new_statuses = c(0,0,1,0,0,1,1,1,0,1,1,1)

call$negoutcome <- 0
#Run the below command wisely, it takes time
call$negoutcome <- as.numeric(sapply(call$call_end_status,myreplace,old=unique(call$call_end_status),new=new_statuses))

#Calculating Number of Negative calls per agent.
agent$negativecalls = 0

#Agents Not in CALL DATASET - logical 
log_agent = agent$agent_id %in% call$agent_id

agent$negativecalls[log_agent] = tapply(call$negoutcome, call$agent_id, sum)

#-Check the above works fine  --- sum(call$negoutcome[call$agent_id == "ABR"])

#Calculating Ratio of Negative calls/total calls
agent$negativity = 0

##0428
agent$negativity = round(agent$negativecalls / agent$Total_CallData_Calls,2)


###------------------------------------------------
#SKILL GROUPINGS: Comparing Skill Groups in Call data and Groups in Agent Data
###-----------------------------------------------

##Skill Groups
call$skillname <- NA
call$skill_name = as.character(call$skill_name)
call$skillname = substr(call$skill_name,0, (nchar(call$skill_name)-5))
#call$skillname[10:40]

old_skill_group = c("GENERAL",NA,"AUT","AT AND ","AT AND T ","DI","TMOBILE TIERTARY ","SPRI","GENERAL ","VERIZO","CREDIT CAR","DIRECT","T-MOBILE_FAMIL","SPRIN","TMOBILE TIERTA","TMOBIL","AT AND","SPRINT ","DIS","TMOBI","TMOBILE ","VERIZ","AU","VERIZON ","LEGA","CLOS","CREDIT CA","COMMERCIA","UTILI","TMOBILE TIERTAR","T-MOBILE_FAMI","JC","DIRECTT","COMMERCI","AT AND T B_M","GENERAL 2_M")
new_skill_group = c("OTHER",NA,"AUTO","ATT","ATT","DISH","TMOBILE","SPRINT","OTHER","VERIZON","CREDIT CARD","DIRECTTV","TMOBILE","SPRINT","TMOBILE","TMOBILE","ATT","SPRINT","DISH","TMOBILE","TMOBILE","VERIZON","AUTO","VERIZON","LEGAL","OTHER","CREDIT CARD","COMMERCIAL","OTHER","TMOBILE","TMOBILE","OTHER","DIRECTTV","COMMERCIAL","ATT","OTHER")
call[c("skillgroup")] <- NA
call[,c("skillgroup")] =sapply(call[,c("skillname")],myreplace,old=old_skill_group,new=new_skill_group)


####0428 Changes :)
call$skillname = NULL
#### Use "skillgroup" for all future computations on SKILLS of the agent
#---------------------------------------------------------------------------

###----------------------------------------------------
#Creating Skill
###---------------------------------------------------
agent$skills = NA
agent$skills[log_agent] = tapply(call$skillgroup, call$agent_id, unique)

agent$skilloutofgroup = 0
agent$skilloutofgroup[log_agent] = mapply(function(v,w){subset(v,!(v %in% w)) },agent$skills[log_agent],agent$usergroup[log_agent])

agent$skillgroupdiff = 0
agent$skillgroupdiff = sapply(agent$skilloutofgroup,length)

####Removing Call Direction from the DATASET CALL 
call$call_direction = NULL
###################

###---------------------------------------
#FEATURE DATASET
###-----------------------------------------

feature_new <- feature
feature_new$CallSpeech <- rowMeans(feature_new[,3:26])
feature_new_CallSpeech <- feature_new[,3:26]
NE1 <- rowSums(feature_new[,27:36]) #25-34
NE2 <- rowSums(feature_new[,47:56])
NE3 <- rowSums(feature_new[,67:76])
NE4 <- rowSums(feature_new[,87:96])
NE5 <- rowSums(feature_new[,107:116])
NE6 <- rowSums(feature_new[,127:136])
NE7 <- rowSums(feature_new[,147:156])
NETotal <- NE1 + NE2 + NE3 + NE4 + NE5 + NE6 + NE7
feature_new$NegativeEmotions <- NETotal/(70)
PE1 <- rowSums(feature_new[,37:46])
PE2 <- rowSums(feature_new[,57:66])
PE3 <- rowSums(feature_new[,77:86])
PE4 <- rowSums(feature_new[,97:106])
PE5 <- rowSums(feature_new[,117:126])
PE6 <- rowSums(feature_new[,137:146])
PE7 <- rowSums(feature_new[,157:166])
PETotal <- PE1 + PE2 + PE3 + PE4 + PE5 + PE6 + PE7
feature_new$PositiveEmotions <- PETotal/(70)
feature_new$PositiveNegativeProportion <- rowMeans(feature_new[, 167:178])

###-------------------------------------------------------------####--------------------------------------
# Synchronising Target Values for each agent in Feature Data. Also checking Target values of agent == Terminated 1|0 of agent data
###----------------------------------------------
call$new_file_audio <- substr(call$audio_file_name,1,34)
feature_new$new_file_audio <- (substr(feature_new$AUDIO.FILE.NAME, 1,34))
tmp1 = call[which(call$new_file_audio %in% feature_new$new_file_audio),c("new_file_audio","agent_id")]
names(call)

tmp2 = feature_new[which(feature_new$new_file_audio %in% call$new_file_audio),]

##Merging agent id to feature
feature_new = merge(x = tmp1,y = tmp2, by.x = "new_file_audio", by.y = "new_file_audio")

# Code to find the target values assigned to each agent
tmp3 = feature_new[which(feature_new$new_file_audio %in% call$new_file_audio),c("new_file_audio","target_value")]
##creating new frame to store File Name | Agent ID | Target Values
target_agent = merge(x = tmp1,y = tmp3, by.x = "new_file_audio", by.y = "new_file_audio")

# Creating a dataframe having columns "agent_id" and "target_value"
tmp4 = data.frame(tapply(target_agent$target_value,target_agent$agent_id,unique))
tmp4 <- cbind(rownames(tmp4), tmp4)
rownames(tmp4) <- NULL
colnames(tmp4) <- c("agent_id","target_value")



# Adding a new column "newtarget_valuee" in agent dataset for further computations
# Null and NA values in target_value columns have been replaced by termiated values for respectve agents
agent = merge(x = agent, y = tmp4 , by = "agent_id", all.x = TRUE)
agent$newtarget_value[agent$target_value == "NA"]  <- agent$terminated[agent$target_value == "NA"]
agent$newtarget_value[agent$target_value == "NULL"]  <- agent$terminated[agent$target_value == "NULL"]

agent$newtarget_value[agent$target_value == "c(0, NA)"] <- 0
agent$newtarget_value[agent$target_value == "c(1, NA)"] <- 1
agent$newtarget_value[agent$target_value == "0"] <- 0
agent$newtarget_value[agent$target_value == "1"] <- 1
target_agent = merge(x = target_agent, y = agent[c("agent_id","newtarget_value")], by = "agent_id", all.x = TRUE)
feature_new = cbind(feature_new,target_agent["newtarget_value"])

#View(feature)

#####-----------

#Calculating Mode of agent skills

getmode <- function(v){
  v = v[!is.na(v)]
  temp <- table(as.vector(v))
  names(temp)[temp == max(temp)]
}

agent$groupmode[log_agent] = tapply(call$skillgroup,call$agent_id,getmode)
agent$groupmode = as.character(agent$groupmode)

####JUST CHECKING IF "new group" was a character
agent$new_group = as.character(agent$new_group)

##ALL NULL VALUES IN NEW GROUP REPLACED BY THE MODE
agent$new_group[is.na(agent$new_group)]=agent$groupmode

###0428
agent$target_value = NULL
#####

#Changing 0428
agent$Call_Median_Duration[is.na(agent_trimmed$Call_Median_Duration)]=0
agent$Total_CallData_Calls[is.na(agent$Total_CallData_Calls)]=0
agent$Total_CallData_Calls = as.numeric(agent$Total_CallData_Calls)
agent$Call_Median_Duration = as.numeric(agent$Call_Median_Duration)
agent$negativity = as.numeric(agent$negativity)

###########DOING BELOW TO REPLACE THE NA values in Average Hours Worked
##Finding the mean of Voluntary resignations 
avgsal_voluntary = mean(agent$avghrsworked[!is.na(agent$term_type) & !is.na(agent$avghrsworked) & agent$term_type ==1 ])

##Finding the mean of InVoluntary resignations 
avgsal_involuntary = mean(agent$avghrsworked[!is.na(agent$term_type) & !is.na(agent$avghrsworked) & agent$term_type ==0 ])

##Replacing all NA's ad 0's in avg salary of voluntary by mean of voluntary
agent$avghrsworked[which(is.na(agent$avghrsworked) & agent$term_type==1)]=avgsal_voluntary
agent$avghrsworked[which(agent$avghrsworked==0 & agent$term_type==1)]=avgsal_voluntary

which(is.na(agent$avghrsworked)) = avgsal_voluntary

##Replacing all NA's and 0's in avg salary of voluntary by mean of voluntary
agent$avghrsworked[which(is.na(agent_trimmed2$avghrsworked) & agent_trimmed2$term_type==0)] = avgsal_involuntary
agent$avghrsworked[which(agent_trimmed2$avghrsworked==0 & agent_trimmed2$term_type==0)]=avgsal_involuntary

##0428  
agent_trimmed = agent[c("terminated","lastgrp","rev_generated","commision","Call_Median_Duration","Total_CallData_Calls",
                      "negativity","skillgroupdiff","avghrsworked")]

##Deleting 49 rows that have all NA values in most columns
agent_trimmed= agent_trimmed[!is.na(agent_trimmed$lastgrp),]

attach(agent_trimmed)
library(rpart)

#########TREE----------------------------
tree = rpart(terminated~.,data=agent_trimmed,control = rpart.control(cp=0.02),method="class")

library(rpart.plot)
rpart.plot(tree,extra=101,type=4)
fancyRpartPlot(tree)
View(agent_trimmed)
##Recall - Confusion Matrix
confusion.advisory_tree <-  table(agent_trimmed[,"terminated"],predict(tree,agent_trimmed,type = "class"))
confusion.advisory_tree 
##Accuracy == 92.7%

####Changing complexity parameter to 0.01 -- reducing pruning
tree2 = rpart(terminated~.,data=agent_trimmed,control = rpart.control(cp=0.01),method="class")
rpart.plot(tree2,extra=101,type=4) ##Does not change , i.e. best splits obtained
fancyRpartPlot(tree2)
########TREE with 2 ---------------------------------

agent_trimmed2 = agent[,c("terminated","term_type","lastgrp","rev_generated","commision","Call_Median_Duration","Total_CallData_Calls",
                                   "negativity","skillgroupdiff","avghrsworked")]

View(agent_trimmed2)
nrow(agent_trimmed2)
##Deleting 49 rows as done for agent_trimmed
agent_trimmed2= agent_trimmed2[!is.na(agent_trimmed2$lastgrp),]

##Deleting rows that have their term type unknown - 16 agents
agent_trimmed2 = agent_trimmed2[!(is.na(agent_trimmed2$term_type) & agent_trimmed2$terminated==1),]

###Changing the value of INVOLUNTARILY left agents to 2
agent_trimmed2$terminated[which(agent_trimmed2$term_type==0 & agent_trimmed2$terminated==1)]=2

###Excluding Term Type
agent_trimmed2$term_type = NULL

#########TREE----------------------------
tree3 = rpart(terminated~.,data=agent_trimmed2,control = rpart.control(cp=0.02),method="class")
print(tree3)

library(rpart.plot)
rpart.plot(tree3,extra=101,type=4)
fancyRpartPlot(tree3)



##Recall - Confusion Matrix
confusion.tree3 <-  table(agent_trimmed2[,"terminated"],predict(tree3,agent_trimmed2,type = "class"))
confusion.tree3 
##Accuracy == 92.7%

####Changing complexity parameter to 0.01 -- reducing pruning
tree4 = rpart(terminated~.,data=agent_trimmed2,control = rpart.control(cp=0.01),method="class")
rpart.plot(tree4,extra=101,type=4) ##Does not change , i.e. best splits obtained
fancyRpartPlot(tree4)
confusion.tree4 <-  table(agent_trimmed2[,"terminated"],predict(tree4,agent_trimmed2,type = "response"))
confusion.tree4 ##Accuracy == 81.25%

####### Logistic Regression for the above 2 datasets - the tree might eat up other important predictors, lets check them
#---------We have not differentiated between Voluntary and Involuntary

attach(agent_trimmed)
lr = glm(terminated ~ .,data=agent_trimmed,family=binomial)
summary(lr)

##AIC = 196.63



###It seems that the Lastgroup with "OTHER" is significant, so we create a dummy for last group = other or not. 

agent_trimmed3 = agent_trimmed 
agent_trimmed3$lastother <- 0

agent_trimmed3$lastgrp[which(agent_trimmed3$lastgrp=="OTHER")] = 1
agent_trimmed3$lastgrp <- NULL



lr1 = glm(terminated ~ .,data=agent_trimmed3,family=binomial)
summary(lr1)

#Null Deviance ; P- Value = 
1-pchisq(318.35,df=241)
##0.0006

#Statistical reducation in Null Deviance by adding the independent variables
1-pchisq(205.19,df=234)
##0.91

##
1-pchisq(318.35-205.19,df=241-234) 
#This gives the p value of the model. it is approximating 0 which means that the null hypothesis can be rejected.
#Null Hypothesis being that there is no significant difference between the predictors for the ones who left and ones who did not leave.


#AIC = 221.19


glm_predicted = predict(lr1,agent_trimmed3,type = "response")
glm_predicted[glm_predicted>=0.5]=1
glm_predicted[glm_predicted<0.5]=0

##Accuracy on Recall
confusion.lr1 = table(agent_trimmed3[,"terminated"],glm_predicted)
(65+131)/249
#Accuracy = 78.7%

#########-------------------------------------

###########################################################
#NEURAL NETS-------------------
###########################################################


#functions
mode <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}

#agg_feature_mean <- function(v,w){
#  tapply(v,w,mean)
#}

scale_01 <- function(x){(x-min(x))/(max(x)-min(x))}

#remove unwanted var
feature_new$new_file_audio <- NULL
feature_new$AUDIO.FILE.NAME <- NULL
feature_new$target_value <- NULL

feature_new_1 <- feature_new[,c(1,181,178,179,180,182,2:177)]

#write.csv(feature_new_1,"feature_new.csv")

feature_agg <- feature_new_1 

#scale and aggregate feature data

#agent and target 

feature_agent_target <- aggregate(newtarget_value ~ agent_id, data = feature_new_1, FUN = mode)
feature_agent_target$newtarget_value <- NA
names(feature_agent_target)[names(feature_agent_target) == "newtarget_value"] <- "target"
feature_agent_target <- merge(feature_agent_target,agent[,c("agent_id","terminated","term_type")],by = "agent_id", all.y = TRUE)
feature_agent_target$target[feature_agent_target$terminated == 1 & feature_agent_target$term_type == 0] <- 0
feature_agent_target$target[feature_agent_target$terminated == 1 & feature_agent_target$term_type == 1] <- 1
feature_agent_target$target[feature_agent_target$terminated == 0] <- 0
feature_agent_target$term_type <- NULL
feature_agent_target$newtarget_value <- NULL
table(feature_agent_target$target)


#scale function
scaled.feature_agg <- scale(feature_agg[,7:182],center = TRUE, scale = TRUE)
scaled.feature_agg<-cbind(feature_agg[,1:6],scaled.feature_agg)

scaled.feature_agg_mean = aggregate(. ~ agent_id, data = scaled.feature_agg, FUN = mean)
scaled.feature_agg_mode = aggregate(. ~ agent_id, data = scaled.feature_agg, FUN = mode)

#scale_01 function
scaled_01.feature_agg <-scale_01(feature_agg[,7:182])
scaled_01.feature_agg<-cbind(feature_agg[,1:6],scaled_01.feature_agg)

scaled_01.feature_agg_mean <- aggregate(. ~ agent_id, data = scaled_01.feature_agg, FUN = mean)
scaled_01.feature_agg_mode <- aggregate(. ~ agent_id, data = scaled_01.feature_agg, FUN = mode)

#scaled_01.feature_agg_mean = as.data.frame(sapply(scaled_01.feature_agg[,c(7:182)],function(v) agg_feature_mean(v,scaled_01.feature_agg$agent_id)))
#scaled_01.feature_agg_mode = as.data.frame(sapply(scaled_01.feature_agg[,c(7:182)],function(v) agg_feature_mode(v,scaled_01.feature_agg$agent_id)))

#pca scaled data
pca_scaled_feature_mean <- prcomp(scaled.feature_agg_mean[,7:182])
summary(pca_scaled_feature_mean)
pca_scaled_feature_mean_ds <- pca_scaled_feature_mean$x[,1:23] #99%

pca_scaled_feature_mode <- prcomp(scaled.feature_agg_mode[,7:182])
summary(pca_scaled_feature_mode)
pca_scaled_feature_mode_ds <- as.data.frame(pca_scaled_feature_mode$x[,1:21]) #99%

#pca scaled_01 data
pca_scaled_01_feature_mean <- prcomp(scaled_01.feature_agg_mean[,7:182])
summary(pca_scaled_01_feature_mean)
pca_scaled_01_feature_mean_ds <- pca_scaled_01_feature_mean$x[,1:4] #98.5%
pca_scaled_01_feature_mean_ds <- cbind(as.character(scaled_01.feature_agg_mean$agent_id),pca_scaled_01_feature_mean_ds)
names(pca_scaled_01_feature_mean_ds)[names(pca_scaled_01_feature_mean_ds)=="V1"] <- "agent_id"


pca_scaled_01_feature_mode <- prcomp(scaled_01.feature_agg_mode[,7:182])
summary(pca_scaled_01_feature_mode)
pca_scaled_01_feature_mode_ds <- as.data.frame(pca_scaled_01_feature_mode$x[,1:6]) #99.2%
pca_scaled_01_feature_mode_ds <- cbind(scaled_01.feature_agg_mode[,"agent_id"],pca_scaled_01_feature_mode_ds)
names(pca_scaled_01_feature_mode_ds)[names(pca_scaled_01_feature_mode_ds)=="scaled_01.feature_agg_mode[, \"agent_id\"]"] <- "agent_id"


#feature category wise

#feature callspeech
feature_new_callspeech <- feature_new_1[,c(1,7:30)]

scaled_01.feature_callspeech_agg <- scale_01(feature_new_callspeech[-1])
scaled_01.feature_callspeech_agg <- cbind(feature_new_callspeech[,"agent_id"],scaled_01.feature_callspeech_agg)
names(scaled_01.feature_callspeech_agg)[names(scaled_01.feature_callspeech_agg)=="feature_new_callspeech[, \"agent_id\"]"] <- "agent_id"

scaled_01.feature_callspeech_agg_mean <- aggregate(. ~ agent_id, data = scaled_01.feature_callspeech_agg, FUN = mean)
scaled_01.feature_callspeech_agg_mode <- aggregate(. ~ agent_id, data = scaled_01.feature_callspeech_agg, FUN = mode)

pca_scaled_01_feature_callspeech_mean <- prcomp(scaled_01.feature_callspeech_agg_mean[-1])
summary(pca_scaled_01_feature_callspeech_mean)
pca_scaled_01_feature_callspeech_mean_ds <- as.data.frame(pca_scaled_01_feature_callspeech_mean$x[,1:6]) #80.75..99.5%


#feature negetiveemotions
feature_new_negativeemotions <- feature_new_1[,c(1,31:40,51:60,71:80,91:100,111:120,131:140,151:160)]

scaled_01.feature_negativeemotions_agg <- scale_01(feature_new_negativeemotions[-1])
scaled_01.feature_negativeemotions_agg <- cbind(feature_new_negativeemotions[,"agent_id"],scaled_01.feature_negativeemotions_agg)
names(scaled_01.feature_negativeemotions_agg)
names(scaled_01.feature_negativeemotions_agg)[names(scaled_01.feature_negativeemotions_agg)=="feature_new_negativeemotions[, \"agent_id\"]"] <- "agent_id"

scaled_01.feature_negetiveemotions_agg_mean <- aggregate(. ~ agent_id, data = scaled_01.feature_negativeemotions_agg, FUN = mean)
scaled_01.feature_negetiveemotions_agg_mode <- aggregate(. ~ agent_id, data = scaled_01.feature_negativeemotions_agg, FUN = mode)

pca_scaled_01_feature_negetiveemotions_mean <- prcomp(scaled_01.feature_negetiveemotions_agg_mean[-1])
summary(pca_scaled_01_feature_negetiveemotions_mean)
pca_scaled_01_feature_negetiveemotions_mean_ds <- as.data.frame(pca_scaled_01_feature_negetiveemotions_mean$x[,1:4]) #92.8..99.3%

#feature positiveemotions
feature_new_positiveemotions <- feature_new_1[,c(1,41:50,61:70,81:90,101:110,121:130,141:150,161:170)]

scaled_01.feature_positiveemotions_agg <- scale_01(feature_new_positiveemotions[-1])
scaled_01.feature_positiveemotions_agg <- cbind(feature_new_positiveemotions[,"agent_id"],scaled_01.feature_positiveemotions_agg)
names(scaled_01.feature_positiveemotions_agg)
names(scaled_01.feature_positiveemotions_agg)[names(scaled_01.feature_positiveemotions_agg)=="feature_new_positiveemotions[, \"agent_id\"]"] <- "agent_id"

scaled_01.feature_positiveemotions_agg_mean <- aggregate(. ~ agent_id, data = scaled_01.feature_positiveemotions_agg, FUN = mean)
scaled_01.feature_positiveemotions_agg_mode <- aggregate(. ~ agent_id, data = scaled_01.feature_positiveemotions_agg, FUN = mode)

pca_scaled_01_feature_positiveemotions_mean <- prcomp(scaled_01.feature_positiveemotions_agg_mean[-1])
summary(pca_scaled_01_feature_positiveemotions_mean)
pca_scaled_01_feature_positiveemotions_mean_ds <- as.data.frame(pca_scaled_01_feature_positiveemotions_mean$x[,1:8]) #85..99.2%

#feature positivenegetiveproportions
feature_new_positivenegativeproportion <- feature_new_1[,c(1,171:182)]

scaled_01.feature_positivenegativeproportion_agg <- scale_01(feature_new_positivenegativeproportion[-1])
scaled_01.feature_positivenegativeproportion_agg <- cbind(feature_new_positivenegativeproportion[,"agent_id"],scaled_01.feature_positivenegativeproportion_agg)
names(scaled_01.feature_positivenegativeproportion_agg)
names(scaled_01.feature_positivenegativeproportion_agg)[names(scaled_01.feature_positivenegativeproportion_agg)=="feature_new_positivenegativeproportion[, \"agent_id\"]"] <- "agent_id"

scaled_01.feature_positivenegativeproportion_agg_mean <- aggregate(. ~ agent_id, data = scaled_01.feature_positivenegativeproportion_agg, FUN = mean)
scaled_01.feature_positivenegativeproportion_agg_mode <- aggregate(. ~ agent_id, data = scaled_01.feature_positivenegativeproportion_agg, FUN = mode)

pca_scaled_01_feature_positivenegativeproportion_mean <- prcomp(scaled_01.feature_positivenegativeproportion_agg_mean[-1])
summary(pca_scaled_01_feature_positivenegativeproportion_mean)
pca_scaled_01_feature_positivenegativeproportion_mean_ds <- as.data.frame(pca_scaled_01_feature_positivenegativeproportion_mean$x[,1:3]) #94.5..99.2%


#create datasets

ds_feature_scaled01_mean <- merge(feature_agent_target,pca_scaled_01_feature_mean_ds,by.x = "agent_id",by.y = "V1", all.y = TRUE)
str(ds_feature_scaled01_mean)
ds_feature_scaled01_mean$PC1 <- as.numeric(as.character(ds_feature_scaled01_mean$PC1))
ds_feature_scaled01_mean$PC2 <- as.numeric(as.character(ds_feature_scaled01_mean$PC2))
ds_feature_scaled01_mean$PC3 <- as.numeric(as.character(ds_feature_scaled01_mean$PC3))
ds_feature_scaled01_mean$PC4 <- as.numeric(as.character(ds_feature_scaled01_mean$PC4))

ds_feature_scaled01_mode <- merge(feature_agent_target,pca_scaled_01_feature_mode_ds,by.x = "agent_id",by.y = "agent_id", all.y = TRUE)
str(ds_feature_scaled01_mode)

ds_feature_scaled01_emotions_mean <- cbind(pca_scaled_01_feature_callspeech_mean_ds$PC1,pca_scaled_01_feature_negetiveemotions_mean_ds$PC1,pca_scaled_01_feature_positiveemotions_mean_ds$PC1,pca_scaled_01_feature_positivenegativeproportion_mean_ds$PC1)
ds_feature_scaled01_emotions_mean <- cbind(as.data.frame(scaled_01.feature_positivenegativeproportion_agg_mean$agent_id),ds_feature_scaled01_emotions_mean)
names(ds_feature_scaled01_emotions_mean)
names(ds_feature_scaled01_emotions_mean)[names(ds_feature_scaled01_emotions_mean)=="scaled_01.feature_positivenegativeproportion_agg_mean$agent_id"] <- "agent_id"
ds_feature_scaled01_emotions_mean <- merge(feature_agent_target,ds_feature_scaled01_emotions_mean,by.x = "agent_id",by.y = "agent_id", all.y = TRUE)


#models
install.packages('neuralnet')
library("neuralnet")

#scaled01_mean
net_feature_scaled01_mean.sqrt <- neuralnet(ds_feature_scaled01_mean$target~ds_feature_scaled01_mean$PC1+ds_feature_scaled01_mean$PC2+ds_feature_scaled01_mean$PC3+ds_feature_scaled01_mean$PC4,ds_feature_scaled01_mean, hidden = 4)
plot(net_feature_scaled01_mean.sqrt)
ds_feature_scaled01_mean_recall <- ds_feature_scaled01_mean[,4:7]
net_feature_scaled01_mean.results <- compute(net_feature_scaled01_mean.sqrt, ds_feature_scaled01_mean_recall) #Run them through the neural network
ls(net_feature_scaled01_mean.results)
ds_feature_scaled01_mean_predicted <- ds_feature_scaled01_mean
ds_feature_scaled01_mean_predicted$predicted <- NA
ds_feature_scaled01_mean_predicted$predicted <- net_feature_scaled01_mean.results$net.result
summary(ds_feature_scaled01_mean_predicted$predicted)
ds_feature_scaled01_mean_predicted$predicted[net_feature_scaled01_mean.results$net.result >= 0.5] <- 1 
ds_feature_scaled01_mean_predicted$predicted[net_feature_scaled01_mean.results$net.result < 0.5] <- 0 
length(ds_feature_scaled01_mean_predicted$agent_id[ds_feature_scaled01_mean_predicted$target == ds_feature_scaled01_mean_predicted$predicted & ds_feature_scaled01_mean_predicted$predicted == 1])
#53/116*100 = 45.68
length(ds_feature_scaled01_mean_predicted$agent_id[ds_feature_scaled01_mean_predicted$target == 1])
#69/116*100 = 59.48
#confusion matrix
table(ds_feature_scaled01_mean_predicted$target,ds_feature_scaled01_mean_predicted$predicted)
net_feature_scaled01_mean.acc = (32+57)/116


#scaled01_mode
net_feature_scaled01_mode.sqrt <- neuralnet(target~PC1+PC2+PC3+PC4+PC5+PC6,ds_feature_scaled01_mode, hidden = 5)
plot(net_feature_scaled01_mode.sqrt)
ds_feature_scaled01_mode_recall <- ds_feature_scaled01_mode[,4:9]
net_feature_scaled01_mode.results <- compute(net_feature_scaled01_mode.sqrt, ds_feature_scaled01_mode_recall) #Run them through the neural network
ds_feature_scaled01_mode_predicted <- ds_feature_scaled01_mode
ds_feature_scaled01_mode_predicted$predicted <- NA
ds_feature_scaled01_mode_predicted$predicted <- net_feature_scaled01_mode.results$net.result
summary(ds_feature_scaled01_mode_predicted$predicted)
ds_feature_scaled01_mode_predicted$predicted[net_feature_scaled01_mode.results$net.result >= 0.5] <- 1 
ds_feature_scaled01_mode_predicted$predicted[net_feature_scaled01_mode.results$net.result < 0.5] <- 0 
length(ds_feature_scaled01_mode_predicted$agent_id[ds_feature_scaled01_mode_predicted$target == ds_feature_scaled01_mode_predicted$predicted & ds_feature_scaled01_mode_predicted$predicted == 1])
66/116*100
length(ds_feature_scaled01_mode_predicted$agent_id[ds_feature_scaled01_mode_predicted$target == 1])
#69/116*100 = 59.48
#confusion matrix
table(ds_feature_scaled01_mode_predicted$target,ds_feature_scaled01_mode_predicted$predicted)
net_feature_scaled01_mode.acc <- (38+57)/116

#scaled01_feature_emotions
net_feature_scaled01_emotions.sqrt <- neuralnet(target~ds_feature_scaled01_emotions_mean$`1`+ds_feature_scaled01_emotions_mean$`2`+ds_feature_scaled01_emotions_mean$`3`+ds_feature_scaled01_emotions_mean$`4`,ds_feature_scaled01_emotions_mean, hidden = 4)
plot(net_feature_scaled01_emotions.sqrt)
ds_feature_scaled01_emotions_mean_recall <- ds_feature_scaled01_emotions_mean[,4:7]
net_feature_scaled01_emotions.results <- compute(net_feature_scaled01_emotions.sqrt, ds_feature_scaled01_emotions_mean_recall) #Run them through the neural network
ds_feature_scaled01_emotions_mean_predicted <- ds_feature_scaled01_emotions_mean
ds_feature_scaled01_emotions_mean_predicted$predicted <- NA
ds_feature_scaled01_emotions_mean_predicted$predicted <- net_feature_scaled01_emotions.results$net.result
summary(ds_feature_scaled01_emotions_mean_predicted$predicted)
ds_feature_scaled01_emotions_mean_predicted$predicted[net_feature_scaled01_emotions.results$net.result >= 0.5] <- 1 
ds_feature_scaled01_emotions_mean_predicted$predicted[net_feature_scaled01_emotions.results$net.result < 0.5] <- 0 
length(ds_feature_scaled01_emotions_mean_predicted$agent_id[ds_feature_scaled01_emotions_mean_predicted$target == ds_feature_scaled01_emotions_mean_predicted$predicted & ds_feature_scaled01_emotions_mean_predicted$predicted == 1])
66/116*100
length(ds_feature_scaled01_emotions_mean_predicted$agent_id[ds_feature_scaled01_emotions_mean_predicted$target == 1])
#69/116*100 = 59.48
#confusion matrix
table(ds_feature_scaled01_emotions_mean_predicted$target,ds_feature_scaled01_emotions_mean_predicted$predicted)
net_feature_scaled01_emotions.acc = (37+60)/116

#lasso

install.packages("glmnet")
library(glmnet)

table(ds_feature_scaled01_mean$target)






