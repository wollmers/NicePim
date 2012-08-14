{
 name: email;
 class: complain;

 assigned_subject: Products complaint is assigned to you: [%%subject%%];
 assigned_body: Dear %%to_person%%,

Products complaint is assigned to you.
Product details: %%prod_id%%(%%supplier%%)
 
### MESSAGE START ###

From\: %%from_login%% (%%from_email%%)
Product\: %%product%%
Subject\: %%subject%%
Message\:
%%message%%

### MESSAGE END   ###

 
 history_subject:In complaints history appeared the new answer to: [%%subject%%];
 history_body: Dear %%to_person%%,
 
In complaints history the new answer has appeared on your submission.
Product details: %%prod_id%%(%%supplier%%)
	
### MESSAGE START ###

From\: %%from_login%% (%%from_email%%)
Subject\: %%subject%%
Message\:
%%message%%

### MESSAGE END   ###

 new_subject: New product complaint received: [%%subject%%];
 new_body:Dear %%to_person%%,
 
You have new complaint.
Product details: %%prod_id%%(%%supplier%%)
 
### MESSAGE START ###

From\: %%from_login%% (%%from_email%%)
Subject\: %%subject%%
Message\:
%%message%%

### MESSAGE END   ###

 post_subject: New product complaint is posted: [%%subject%%];
 post_body: Dear %%to_person%%,
 
New complaint is posted to you. Noticed by %%from_person%%.
Product details: %%prod_id%%(%%supplier%%)
 
### MESSAGE START ###

From\: %%from_login%% (%%from_email%%)
Subject\: %%subject%%
Message\:
%%message%%

### MESSAGE END   ###

to_sender_subject: Waiting for your response on complaint: [%%subject%%];
to_sender_body:Dear %%to_person%%,

Please, response on message about your complaint.
Product details: %%prod_id%%(%%supplier%%)	
 
### MESSAGE START ###

From\: %%from_login%% (%%from_email%%)
Subject\: %%subject%%
Message\:
%%message%%

### MESSAGE END   ###
	
close_subject: Complaint closed: [%%subject%%];
close_body:Dear %%to_person%%,

Your complaint "%%complaint_subject%%" is closed.
Product details: %%prod_id%%(%%supplier%%)
 		
### MESSAGE START ###

From\: %%from_login%% (%%from_email%%)
Subject\: %%subject%%
Message\:
%%message%%

### MESSAGE END   ###
}
