function sendolmail(to,cc,subject,body,attachments)
%Sends email using MS Outlook. The format of the function is 
%Similar to the SENDMAIL command.
% Create object and set parameters.
h = actxserver('outlook.Application');
mail = h.CreateItem('olMail');
mail.Subject = subject;
mail.To = to;
mail.CC=cc;
mail.BodyFormat = 'olFormatHTML';
mail.HTMLBody = body;
% Add attachments, if specified.
if nargin == 5
    for i = 1:length(attachments)
        mail.attachments.Add(attachments{i});
    end
end
% Send message and release object.
mail.Send;
h.release;
end