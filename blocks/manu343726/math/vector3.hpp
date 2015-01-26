
#ifndef VECTOR_3D_HPP
#define VECTOR_3D_HPP

#include <manu343726/portable_cpp/specifiers.hpp>
#include <boost/operators.hpp>
#include <boost/lexical_cast.hpp>
#include <iostream>
#include <string>
#include <tuple>
#include <cmath>

namespace math
{
	template<typename T>
	struct vector3 
	     : boost::addable< vector3<T>             // vector + vector
    	 , boost::subtractable< vector3<T>        // vector - vector
    	 , boost::dividable2< vector3<T>, T       // vector / T
    	 , boost::multipliable2< vector3<T>, T    // vector * T, T * vector
    	 , boost::equality_comparable< vector3<T> // vector != vector
      > > > > >
	{
		T x, y, z;

		vector3() : vector3{0, 0, 0}
		{}

		vector3(T xx, T yy, T zz) :
			x{xx},
			y{yy},
			z{zz}
		{}

		template<typename U>
		explicit vector3(const vector3<U>& v) : vector3{v.x, v.y, v.z}
		{}

		vector3(const vector3& begin, const vector3& end) :
			x{end.x - begin.x},
			y{end.y - begin.y},
			z{end.z - begin.z}
		{}

		T squared_length() const NOEXCEPT
		{
			return x*x + y*y + z*z;
		}

		T length() const NOEXCEPT
		{
			return std::sqrt(squared_length());
		}

		vector3& operator+=(const vector3& v)
		{
			x += v.x;
			y += v.y;
			z += v.z;

			return *this;
		}

		vector3& operator-=(const vector3& v)
		{
			x -= v.x;
			y -= v.y;
			z -= v.z;

			return *this;
		}

		vector3& operator*=(T v)
		{
			x *= v;
			y *= v;
			z *= v;

			return *this;
		}

		vector3& operator/=(T v)
		{
			x /= v;
			y /= v;
			z /= v;

			return *this;
		}

		friend T operator*(const vector3& lhs, const vector3& rhs)
		{
			return lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z;
		}

		friend std::ostream& operator<<(std::ostream& os, const vector3& v)
		{
			return os << "(" << v.x << "," << v.y << "," << v.z << ")";
		}

		friend std::istream& operator>>(std::istream& is, vector3& v)
		{
			char placeholder;

			return is >> placeholder >> v.x >> placeholder >> v.y >> placeholder >> v.z >> placeholder;
		}

		std::string to_string() const
		{
			return boost::lexical_cast<std::string>(*this);
		}

		friend bool operator==(const vector3& lhs, const vector3& rhs)
		{
			return std::tie(lhs.x, lhs.y, lhs.z) == std::tie(rhs.x, rhs.y, rhs.z);
		}
	};
}

#endif /* VECTOR_2D_HPP */