/*
Copyright 2022 SUSE LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

// Code generated by main. DO NOT EDIT.

package v1beta1

import (
	v1beta1 "github.com/rancher/elemental-operator/pkg/apis/elemental.cattle.io/v1beta1"
	"github.com/rancher/lasso/pkg/controller"
	"github.com/rancher/wrangler/pkg/schemes"
	"k8s.io/apimachinery/pkg/runtime/schema"
)

func init() {
	schemes.Register(v1beta1.AddToScheme)
}

type Interface interface {
	MachineInventory() MachineInventoryController
	MachineInventorySelector() MachineInventorySelectorController
	MachineInventorySelectorTemplate() MachineInventorySelectorTemplateController
	MachineRegistration() MachineRegistrationController
	ManagedOSImage() ManagedOSImageController
	ManagedOSVersion() ManagedOSVersionController
	ManagedOSVersionChannel() ManagedOSVersionChannelController
}

func New(controllerFactory controller.SharedControllerFactory) Interface {
	return &version{
		controllerFactory: controllerFactory,
	}
}

type version struct {
	controllerFactory controller.SharedControllerFactory
}

func (c *version) MachineInventory() MachineInventoryController {
	return NewMachineInventoryController(schema.GroupVersionKind{Group: "elemental.cattle.io", Version: "v1beta1", Kind: "MachineInventory"}, "machineinventories", true, c.controllerFactory)
}
func (c *version) MachineInventorySelector() MachineInventorySelectorController {
	return NewMachineInventorySelectorController(schema.GroupVersionKind{Group: "elemental.cattle.io", Version: "v1beta1", Kind: "MachineInventorySelector"}, "machineinventoryselectors", true, c.controllerFactory)
}
func (c *version) MachineInventorySelectorTemplate() MachineInventorySelectorTemplateController {
	return NewMachineInventorySelectorTemplateController(schema.GroupVersionKind{Group: "elemental.cattle.io", Version: "v1beta1", Kind: "MachineInventorySelectorTemplate"}, "machineinventoryselectortemplates", true, c.controllerFactory)
}
func (c *version) MachineRegistration() MachineRegistrationController {
	return NewMachineRegistrationController(schema.GroupVersionKind{Group: "elemental.cattle.io", Version: "v1beta1", Kind: "MachineRegistration"}, "machineregistrations", true, c.controllerFactory)
}
func (c *version) ManagedOSImage() ManagedOSImageController {
	return NewManagedOSImageController(schema.GroupVersionKind{Group: "elemental.cattle.io", Version: "v1beta1", Kind: "ManagedOSImage"}, "managedosimages", true, c.controllerFactory)
}
func (c *version) ManagedOSVersion() ManagedOSVersionController {
	return NewManagedOSVersionController(schema.GroupVersionKind{Group: "elemental.cattle.io", Version: "v1beta1", Kind: "ManagedOSVersion"}, "managedosversions", true, c.controllerFactory)
}
func (c *version) ManagedOSVersionChannel() ManagedOSVersionChannelController {
	return NewManagedOSVersionChannelController(schema.GroupVersionKind{Group: "elemental.cattle.io", Version: "v1beta1", Kind: "ManagedOSVersionChannel"}, "managedosversionchannels", true, c.controllerFactory)
}