package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func Test(t *testing.T) {
	t.Parallel()

	terraformTestOptions := configureTestOptions()
	defer terraform.WorkspaceSelectOrNew(t, terraformTestOptions, "default")
	terraform.WorkspaceSelectOrNew(t, terraformTestOptions, "terratest")
	defer terraform.Destroy(t, terraformTestOptions)
	terraform.InitAndApply(t, terraformTestOptions)

	terraformOptions := configureInfrastructureOptions()
	defer terraform.WorkspaceSelectOrNew(t, terraformOptions, "default")
	terraform.WorkspaceSelectOrNew(t, terraformOptions, "terratest")
	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	checkOutput(t, terraformOptions)
	checkInstances(t, terraformOptions)
	checkMockInstance(t, terraformTestOptions)
}

func configureInfrastructureOptions() *terraform.Options {
	return &terraform.Options{
		TerraformDir: "../screen-scraper-terraform",

		Vars: map[string]interface{}{
			"prefix": "C24519-test",
		},
	}
}

func configureTestOptions() *terraform.Options {
	return &terraform.Options{
		TerraformDir: ".",

		Vars: map[string]interface{}{
			"prefix": "C24519-test",
		},
	}
}

func checkOutput(t *testing.T, terraformOptions *terraform.Options) {
	expectedVpcCidrBlock := terraform.Output(t, terraformOptions, "expected_vpc_cidr")
	actualVprCidrBlock := terraform.Output(t, terraformOptions, "vpc_cidr_block")

	assert.Equal(t, expectedVpcCidrBlock, actualVprCidrBlock)
}

func checkInstances(t *testing.T, terraformOptions *terraform.Options) {
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

func checkMockInstance(t *testing.T, terraformTestOptions *terraform.Options) {
	region := terraform.Output(t, terraformTestOptions, "region")
	instanceTag := terraform.Output(t, terraformTestOptions, "instance_tag")
	instanceId := terraform.Output(t, terraformTestOptions, "instance_id")
	actualInstanceIds := aws.GetEc2InstanceIdsByFilters(t,
		region,
		map[string][]string{"tag:Name": {instanceTag},
			"instance-state-name": {"running"}})

	assert.Equal(t, instanceId, actualInstanceIds[0])
}
