package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

var terraformOptions = &terraform.Options{
	TerraformDir: "../screen-scraper-terraform",

	// Variables to pass to our Terraform code using -var options
	//Vars: map[string]interface{}{
	//	"example": expectedText,

	// We also can see how lists and maps translate between terratest and terraform.
	//	"example_list": expectedList,
	//	"example_map":  expectedMap,
	//},

	// Variables to pass to our Terraform code using -var-file options
	//VarFiles: []string{"varfile.tfvars"},

	// Disable colors in Terraform commands so its easier to parse stdout/stderr
	//NoColor: true,
}

func Test(t *testing.T) {
	t.Parallel()

	// defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	checkOutput(t)
	checkInstances(t)
}

func checkOutput(t *testing.T) {
	expectedVprCidrBlock := "10.32.0.0/16"
	vprCidrBlock := terraform.Output(t, terraformOptions, "vpc_cidr_block")
	assert.Equal(t, expectedVprCidrBlock, vprCidrBlock)
}

func checkInstances(t *testing.T) {
	instanceTags := terraform.OutputList(t, terraformOptions, "instance_tags")
	instanceIds := terraform.OutputList(t, terraformOptions, "instance_ids")
	for index, instanceTag := range instanceTags {
		actualInstanceIds := aws.GetEc2InstanceIdsByTag(t, "eu-west-2", "Name", instanceTag)
		assert.Equal(t, instanceIds[index], actualInstanceIds[0])
	}
}
