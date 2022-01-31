package config_test

import (
	"context"
	"io/ioutil"
	"os"
	"time"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
	. "github.com/rancher-sandbox/os2/pkg/config"
)

var _ = Describe("os2 config unit tests", func() {

	var c Config

	BeforeEach(func() {
		c = Config{}
	})

	Context("Convert to environment configuration", func() {
		It("Handle empty config", func() {
			c = Config{}
			e, err := ToEnv(c)
			Expect(err).ToNot(HaveOccurred())
			Expect(e).To(BeEmpty())
		})

		It("Converts to env slice installation parameters", func() {
			c = Config{
				Data: map[string]interface{}{
					"random": "data",
				},
				SSHAuthorizedKeys: []string{"github:mudler"},
				RancherOS: RancherOS{
					Install: Install{
						Automatic:       true,
						ForceEFI:        true,
						RegistrationURL: "Foo",
						ISOURL:          "http://foo.bar",
					},
				},
			}
			e, err := ToEnv(c)
			Expect(err).ToNot(HaveOccurred())
			Expect(len(e)).To(Equal(5))
			Expect(e).To(
				ContainElements(
					"SSH_AUTHORIZED_KEYS=[github:mudler]",
					"_COS_INSTALL_AUTOMATIC=true",
					"_COS_INSTALL_REGISTRATION_URL=Foo",
					"_COS_INSTALL_ISO_URL=http://foo.bar",
					"_COS_INSTALL_FORCE_EFI=true",
				),
			)
		})
	})

	It("Converts to env slice installation parameters", func() {
		f, err := ioutil.TempFile("", "xxxxtest")
		Expect(err).ToNot(HaveOccurred())
		defer os.Remove(f.Name())

		ioutil.WriteFile(f.Name(), []byte(`
rancheros:
 install:
   registrationUrl: "foobaz"
`), os.ModePerm)

		ctx, cancel := context.WithTimeout(context.Background(), 1*time.Second)
		defer cancel()
		c, err := ReadConfig(ctx, f.Name(), false)
		Expect(err).ToNot(HaveOccurred())
		Expect(c.RancherOS.Install.RegistrationURL).To(Equal("foobaz"))
	})
})