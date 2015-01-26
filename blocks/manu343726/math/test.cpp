
#include <manu343726/math/vector3.hpp>
#include <manu343726/bandit/bandit.h>

using namespace bandit;

namespace m = math;

go_bandit([]()
{
	describe("vector3", []()
	{
		describe("arithmetic", []()
		{
			it("add", []()
			{
				AssertThat((m::vector3<float>{1,2,3} + m::vector3<float>{4,5,6}), Is().EqualTo(m::vector3<float>{5,7,9}));
			});

			it("sub", []()
			{
				AssertThat((m::vector3<float>{5,7,9} - m::vector3<float>{4,5,6}), Is().EqualTo(m::vector3<float>{1,2,3}));
			});

			it("mul", []()
			{
				AssertThat((m::vector3<float>{1,2,3} * 5), Is().EqualTo(m::vector3<float>{5, 10, 15}));
				AssertThat((5 * m::vector3<float>{1,2,3}), Is().EqualTo(m::vector3<float>{5, 10, 15}));
			});

			it("div", []()
			{
				AssertThat((m::vector3<float>{5, 10, 15} / 5), Is().EqualTo(m::vector3<float>{1,2,3}));
			});

			it("mul (scalar)", []()
			{
				AssertThat((m::vector3<float>{1,1,1} * m::vector3<float>{1,1,1}), Is().EqualTo(3));
			});
		});

		describe("input/output", []()
		{
			it("vector --> string", []()
			{
				AssertThat(boost::lexical_cast<std::string>(m::vector3<int>{1,2,3}), Is().EqualTo("(1,2,3)"));
			});

			it("string --> vector", []()
			{
				AssertThat(boost::lexical_cast<m::vector3<int>>("(1,2,3)"), Is().EqualTo(m::vector3<int>{1,2,3}));
			});
		});
	});
});

int main(int argc, char* argv[])
{
	bandit::run(argc, argv);
}
