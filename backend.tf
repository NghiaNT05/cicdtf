terraform{
    backend "s3" {
        bucket = "terraformstate-905418321318"
        key = "state"
        region = "ap-southeast-1"
        dynamodb_table = "mydynamotable"
    }
}