codeunit 60100 "Subscriber Codeunit"
{
    SingleInstance = true;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::ReportManagement, OnGetFilename, '', true, true)]
    local procedure OnGetFilename(ReportID: Integer; Caption: Text[250]; ObjectPayload: JsonObject; FileExtension: Text[30]; ReportRecordRef: RecordRef; var Filename: Text; var Success: Boolean)
    var
        Job: Record Job;
        FileNameLbl: Label '%1 CSI Quote %2 %3';
    begin
        if ReportID = Report::"Project Summary" then begin
            if Job.Get(JobNo) then begin
                Filename := StrSubstNo(FileNameLbl, Job."No.", Job."Bill-to Name", Job."Service Item No.") + FileExtension;
                Success := true;
            end;
        end;
    end;

    procedure GetJobNo(var JobTask: Record "Job Task")
    begin
        JobNo := JobTask."Job No.";
    end;

    var
        JobNo: Code[20];

}
