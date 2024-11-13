pageextension 60100 "Job Task Subform Ext" extends "Job Task Lines Subform"
{
    actions
    {
        addlast(processing)
        {
            action("ProjectSummaryReport")
            {
                Caption = 'Print Project Quote';
                Image = PrintReport;
                ApplicationArea = all;
                trigger OnAction()
                var
                    Job: Record Job;
                    Parameter: Text;
                    JobTaskLines: Record "Job Task";
                    SortingOrderTxt: Text;
                    JobNo: Text;
                    Format: ReportFormat;
                    OutStream: OutStream;
                    Tempblob: Codeunit "Temp Blob";
                    SubcriberCodeunit: Codeunit "Subscriber Codeunit";
                begin

                    Clear(SortingOrderTxt);
                    Clear(Parameter);
                    JobTaskLines.Reset();
                    CurrPage.SetSelectionFilter(JobTaskLines);
                    JobTaskLines.Copy(Rec);
                    if JobTaskLines.FindSet() then
                        repeat
                            if SortingOrderTxt = '' then
                                SortingOrderTxt := JobTaskLines."Sorting Order"
                            else
                                SortingOrderTxt := SortingOrderTxt + '|' + JobTaskLines."Sorting Order";
                        until JobTaskLines.Next() = 0;
                    SubcriberCodeunit.GetJobNo(JobTaskLines);
                    Parameter := '<?xml version="1.0" standalone="yes"?><ReportParameters name="Project Summary" id="60107"><DataItems><DataItem name="Job">VERSION(1) SORTING(Field1) WHERE(Field1=1(';
                    Parameter += JobTaskLines."Job No.";
                    Parameter += '))</DataItem><DataItem name="Job Task">VERSION(1) SORTING(Field1,Field2) WHERE(Field50125=1(';
                    // Parameter += SortingOrderTxt;
                    Parameter += '))</DataItem><DataItem name="Integer">VERSION(1) SORTING(Field1)</DataItem></DataItems></ReportParameters>';
                    Report.Print(Report::"Project Summary", Parameter);
                end;
            }
        }
    }
}
