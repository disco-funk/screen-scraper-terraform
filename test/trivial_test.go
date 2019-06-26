package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

var terraformOptions = &terraform.Options{
	TerraformDir: "../screen-scraper-terraform",

	Vars: map[string]interface{}{
		"prefix": "C24519-mancs",
	},
}


func Test(t *testing.T) {
	t.Parallel()

	terraform.WorkspaceSelectOrNew(t, terraformOptions, "terratest-mancs")
	defer terraform.WorkspaceSelectOrNew(t, terraformOptions, "default")

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	checkOutput(t)
	checkInstances(t)
}

func checkOutput(t *testing.T) {
	expectedVpcCidrBlock := terraform.Output(t, terraformOptions, "expected_vpc_cidr")
	acutalVprCidrBlock := terraform.Output(t, terraformOptions, "vpc_cidr_block")

	assert.Equal(t, expectedVpcCidrBlock, acutalVprCidrBlock)
}

func checkInstances(t *testing.T) {
	region := terraform.Output(t, terraformOptions, "region")
	instanceTags := terraform.OutputList(t, terraformOptions, "instance_tags")
	instanceIds := terraform.OutputList(t, terraformOptions, "instance_ids")

	for index, instanceTag := range instanceTags {
		actualInstanceIds := aws.GetEc2InstanceIdsByFilters(t,
			region,
			map[string][]string{"tag:Name": {instanceTag},
				"instance-state-name": {"running"}})
		assert.Equal(t, instanceIds[index], actualInstanceIds[0])
	}
}
